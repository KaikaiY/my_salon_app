class TimeSlot < ApplicationRecord
  belongs_to :treatment_day

  validates :start_time, :end_time, presence: true
  validate :start_time_must_be_before_end_time

  private

  def start_time_must_be_before_end_time
    return if start_time.blank? || end_time.blank?
    return if start_time < end_time

    errors.add(:start_time, "は終了時刻より前にしてください")
  end
end
