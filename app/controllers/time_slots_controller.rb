class TimeSlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_treatment_day_manager!, except: %i[index]
  before_action :set_treatment_day, except: %i[index]
  before_action :ensure_treatment_day_active!, except: %i[index]
  before_action :set_time_slot, only: %i[edit update destroy]

  def index
    @time_slots = time_slot_scope.includes(treatment_day: %i[company therapist]).order("treatment_days.date ASC", :start_time)
  end

  def new
    @time_slot = @treatment_day.time_slots.new
  end

  def create
    if bulk_create?
      create_bulk_time_slots
      return
    end

    @time_slot = @treatment_day.time_slots.new(time_slot_params)
    if @time_slot.save
      redirect_to treatment_day_path(@treatment_day), notice: "時間枠を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @time_slot.update(time_slot_params)
      redirect_to treatment_day_path(@treatment_day), notice: "時間枠を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @time_slot.reservations.exists?
      redirect_to treatment_day_path(@treatment_day), alert: "予約履歴がある時間枠は削除できません"
    else
      @time_slot.destroy
      redirect_to treatment_day_path(@treatment_day), notice: "時間枠を削除しました"
    end
  end

  private

  def create_bulk_time_slots
    @time_slot = @treatment_day.time_slots.new(time_slot_params)

    unless @time_slot.valid?
      render :new, status: :unprocessable_content
      return
    end

    time_slots = build_bulk_time_slots

    if time_slots.empty?
      @time_slot.errors.add(:base, "20分以上の時間を指定してください")
      render :new, status: :unprocessable_content
      return
    end

    TimeSlot.transaction do
      time_slots.each(&:save!)
    end

    redirect_to treatment_day_path(@treatment_day), notice: "#{time_slots.count}件の時間枠を登録しました"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def build_bulk_time_slots
    interval = 20.minutes
    current_time = time_slot_datetime(time_slot_params[:start_time])
    end_time = time_slot_datetime(time_slot_params[:end_time])
    time_slots = []

    while current_time + interval <= end_time
      time_slots << @treatment_day.time_slots.new(
        start_time: current_time,
        end_time: current_time + interval
      )
      current_time += interval
    end

    time_slots
  end

  def time_slot_datetime(value)
    Time.zone.parse(value.to_s)
  end

  def bulk_create?
    ActiveModel::Type::Boolean.new.cast(params.dig(:time_slot, :bulk_create))
  end

  def time_slot_scope
    scope = TimeSlot.joins(:treatment_day).where.not(treatment_days: { status: TreatmentDay.statuses[:cancelled] })

    if current_user.admin?
      scope
    elsif current_user.company_manager?
      scope.where(treatment_days: { company_id: current_user.company_id })
    elsif current_user.therapist?
      scope.where(treatment_days: { therapist_id: current_user.id })
    elsif current_user.employee?
      scope
        .where(treatment_days: { company_id: current_user.company_id })
        .where.not(id: Reservation.where.not(status: :cancelled).select(:time_slot_id))
    else
      TimeSlot.none
    end
  end

  def set_treatment_day
    @treatment_day = treatment_day_scope.find_by(id: params[:treatment_day_id])

    redirect_to root_path, alert: "権限がありません" unless @treatment_day
  end

  def set_time_slot
    @time_slot = @treatment_day.time_slots.find_by(id: params[:id])

    redirect_to treatment_day_path(@treatment_day), alert: "時間枠が見つかりません" unless @time_slot
  end

  def ensure_treatment_day_active!
    return unless @treatment_day&.cancelled?

    redirect_to treatment_day_path(@treatment_day), alert: "中止された施術日の時間枠は操作できません"
  end

  def time_slot_params
    params.require(:time_slot).permit(:start_time, :end_time)
  end

end
