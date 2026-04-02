class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def ensure_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "権限がありません"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name invitation_token])
  end
end
