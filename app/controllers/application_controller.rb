class ApplicationController < ActionController::Base
  before_action :basic_auth
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def ensure_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: '権限がありません'
  end

  def treatment_day_scope
    return TreatmentDay.all if current_user.admin?

    TreatmentDay.where(company: current_user.company)
  end

  def ensure_treatment_day_manager!
    return if current_user&.admin? || current_user&.company_manager?

    redirect_to root_path, alert: '権限がありません'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name invitation_token])
  end

  private

  def basic_auth
    return unless Rails.env.production?

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
