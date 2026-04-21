class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_invitation, only: %i[approve send_email_confirmation send_email]

  def index
    @invitations = Invitation.includes(:company, :user).recent_first
  end

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = current_user.sent_invitations.build(invitation_params)

    if @invitation.save
      redirect_to invitations_path, notice: '招待URLを作成しました。招待一覧から対象ユーザーに共有できます。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    unless @invitation.accepted? && @invitation.user.present?
      redirect_to invitations_path, alert: '承認できる状態ではありません'
      return
    end

    ActiveRecord::Base.transaction do
      @invitation.user.update!(active: true)
      @invitation.update!(status: :approved, approved_at: Time.current)
    end

    delivery_alert = send_approval_notification(@invitation)

    redirect_to invitations_path,
                notice: 'ユーザーを承認しました。対象ユーザーはログインできるようになりました。',
                alert: delivery_alert
  end

  def send_email_confirmation
    unless invitation_sendable?(@invitation)
      redirect_to invitations_path, alert: '招待メールを送信できる状態ではありません'
      return
    end
  end

  def send_email
    unless invitation_sendable?(@invitation)
      redirect_to invitations_path, alert: '招待メールを送信できる状態ではありません'
      return
    end

    InvitationMailer.invitation_email(@invitation).deliver_now

    redirect_to invitations_path, notice: '招待メールを送信しました。'
  rescue StandardError => e
    Rails.logger.error("Invitation email failed for invitation #{@invitation.id}: #{e.class} - #{e.message}")
    redirect_to invitations_path, alert: '招待メールの送信に失敗しました。メール設定を確認してください。'
  end

  private

  def set_invitation
    @invitation = Invitation.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :company_id, :role, :expires_at)
  end

  def send_approval_notification(invitation)
    InvitationMailer.approval_notification(invitation).deliver_now
    nil
  rescue StandardError => e
    Rails.logger.error("Approval notification failed for invitation #{invitation.id}: #{e.class} - #{e.message}")
    '承認メールの送信に失敗しました。メール設定を確認してください。'
  end

  def invitation_sendable?(invitation)
    invitation.available_for_signup?
  end
end
