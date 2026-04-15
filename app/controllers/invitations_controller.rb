class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_invitation, only: :approve

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

    redirect_to invitations_path, notice: 'ユーザーを承認しました。対象ユーザーはログインできるようになりました。'
  end

  private

  def set_invitation
    @invitation = Invitation.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :company_id, :role, :expires_at)
  end
end
