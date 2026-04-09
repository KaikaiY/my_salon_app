class TimeSlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_treatment_day_manager!
  before_action :set_treatment_day
  before_action :set_time_slot, only: %i[edit update]

  def new
    @time_slot = @treatment_day.time_slots.new
  end

  def create
    @time_slot = @treatment_day.time_slots.new(time_slot_params)

    if @time_slot.save
      redirect_to treatment_day_path(@treatment_day), notice: "時間枠を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @time_slot.update(time_slot_params)
      redirect_to treatment_day_path(@treatment_day), notice: "時間枠を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_treatment_day
    @treatment_day = treatment_day_scope.find(params[:treatment_day_id])
  end

  def set_time_slot
    @time_slot = @treatment_day.time_slots.find(params[:id])
  end

  def time_slot_params
    params.require(:time_slot).permit(:start_time, :end_time)
  end

end

