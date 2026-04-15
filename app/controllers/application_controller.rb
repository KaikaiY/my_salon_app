class ApplicationController < ActionController::Base
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
end
