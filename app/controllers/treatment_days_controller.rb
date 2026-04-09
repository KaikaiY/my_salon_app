class TreatmentDaysController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_treatment_day_manager!
  before_action :set_treatment_day, only: %i[show edit update]

  def index
    @treatment_days = treatment_day_scope.includes(:company, :therapist).order(date: :desc)
  end

  def show
  end

  def new
    @treatment_day = TreatmentDay.new
  end

  def create
    @treatment_day = TreatmentDay.new(treatment_day_params)
    @treatment_day.created_by = current_user
    assign_company_for_company_manager

    if @treatment_day.save
      redirect_to treatment_day_path(@treatment_day), notice: "施術日を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    assign_company_for_company_manager

    if @treatment_day.update(treatment_day_params)
      redirect_to treatment_day_path(@treatment_day), notice: "施術日を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_treatment_day
    @treatment_day = treatment_day_scope.find(params[:id])
  end


  def treatment_day_params
    permitted_params = params.require(:treatment_day).permit(:date, :booking_source, :status, :note, :company_id, :therapist_id)
    return permitted_params if current_user.admin?

    permitted_params.except(:company_id)
  end

  def assign_company_for_company_manager
    return if current_user.admin?

    @treatment_day.company = current_user.company
  end

  
end
