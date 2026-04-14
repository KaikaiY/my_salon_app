class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_employee!, only: %i[new create]
  before_action :set_time_slot, only: %i[new create]
  before_action :set_reservation, only: %i[show cancel]

  def index
    @reservations = reservation_scope.includes(:user, time_slot: :treatment_day).order(created_at: :desc)
  end

  def show
  end

  def new
    @reservation = current_user.reservations.new(time_slot: @time_slot)
  end

  def create
    @reservation = current_user.reservations.new(reservation_params.merge(time_slot: @time_slot, status: :reserved))

    if @reservation.save
      redirect_to reservation_path(@reservation), notice: "予約しました。予約内容を確認してください。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def cancel
    if @reservation.reserved?
      @reservation.update(status: :cancelled)
      redirect_to reservation_path(@reservation), notice: "予約をキャンセルしました。"
    else
      redirect_to reservation_path(@reservation), alert: "この予約はキャンセルできません"
    end
  end

  private

  def ensure_employee!
    return if current_user&.employee?

    redirect_to root_path, alert: "権限がありません"
  end

  def set_time_slot
    @treatment_day = TreatmentDay.where(company: current_user.company).find_by(id: params[:treatment_day_id])

    unless @treatment_day
      redirect_to root_path, alert: "予約できない施術日です"
      return
    end

    @time_slot = @treatment_day.time_slots.find_by(id: params[:time_slot_id])

    redirect_to root_path, alert: "予約できない時間枠です" unless @time_slot
  end

  def set_reservation
    @reservation = reservation_scope.find_by(id: params[:id])

    redirect_to reservations_path, alert: "予約が見つかりません" unless @reservation
  end

  def reservation_scope
    return Reservation.all if current_user.admin?

    if current_user.company_manager?
      return Reservation.joins(time_slot: :treatment_day).where(treatment_days: { company_id: current_user.company_id })
    end

    if current_user.therapist?
      return Reservation.joins(time_slot: :treatment_day).where(treatment_days: { therapist_id: current_user.id })
    end

    current_user.reservations
  end

  def reservation_params
    params.require(:reservation).permit(:note)
  end
end
