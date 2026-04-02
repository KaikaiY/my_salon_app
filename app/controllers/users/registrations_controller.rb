class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_invitation_from_token, only: %i[new create]

  def new
    unless valid_invitation?
      redirect_to root_path, alert: "有効な招待URLから登録してください"
      return
    end

    build_resource(email: @invitation.email)
    resource.name = ""
    clean_up_passwords resource
    set_minimum_password_length
  end

  def create
    unless valid_invitation?
      build_resource
      resource.validate
      redirect_to root_path, alert: "招待URLの有効期限が切れているか、無効です"
      return
    end

    build_resource(sign_up_params.except(:invitation_token))
    resource.email = @invitation.email
    resource.company = @invitation.company
    resource.role = @invitation.role
    resource.active = false

    if resource.save
      @invitation.update!(status: :accepted, accepted_at: Time.current, user: resource)
      redirect_to new_user_session_path, notice: "登録申請を受け付けました。管理者の承認後にログインできます。"
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_invitation_from_token
    token = params[:invitation_token] || params.dig(:user, :invitation_token)
    @invitation = Invitation.find_by(token: token)
    @invitation&.mark_as_expired_if_needed!
  end

  def valid_invitation?
    @invitation&.available_for_signup?
  end
end
