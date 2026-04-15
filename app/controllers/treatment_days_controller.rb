class TreatmentDaysController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_treatment_day_manager!
  before_action :set_treatment_day, only: %i[show edit update cancel reopen]

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
      redirect_to treatment_day_path(@treatment_day), notice: '施術日を登録しました。時間枠の作成に進めます。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    assign_company_for_company_manager

    if @treatment_day.update(treatment_day_params)
      redirect_to treatment_day_path(@treatment_day), notice: '施術日を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    if @treatment_day.cancelled?
      redirect_to treatment_day_path(@treatment_day), alert: 'この施術日はすでに中止されています'
    else
      @treatment_day.update(status: :cancelled)
      cancel_reserved_reservations
      redirect_to treatment_day_path(@treatment_day), notice: '施術日を中止しました。関連する予約中の予約もキャンセルされました。'
    end
  end

  def reopen
    unless @treatment_day.cancelled?
      redirect_to treatment_day_path(@treatment_day), alert: 'この施術日は再開できません'
      return
    end

    @treatment_day.update(status: :pending)
    redirect_to treatment_day_path(@treatment_day), notice: '施術日を再開しました。必要に応じて時間枠や予約状況を確認してください。'
  end

  private

  def set_treatment_day
    @treatment_day = treatment_day_scope.find_by(id: params[:id])

    redirect_to root_path, alert: '権限がありません' unless @treatment_day
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

  def cancel_reserved_reservations
    @treatment_day.time_slots.includes(:reservations).each do |time_slot|
      time_slot.reservations.reserved.each do |reservation|
        reservation.update(status: :cancelled)
      end
    end
  end
end
