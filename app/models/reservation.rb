class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :time_slot
  has_one :treatment_day, through: :time_slot

  enum :status, {
    reserved: 0,
    cancelled: 1,
    completed: 2
  }

  validates :status, presence: true
  validate :time_slot_must_not_have_active_reservation

  private

  def time_slot_must_not_have_active_reservation
    return if time_slot.blank?
    return if cancelled?

    if Reservation.where(time_slot: time_slot).where.not(status: :cancelled).where.not(id: id).exists?
      errors.add(:time_slot, "はすでに予約されています")
    end
  end
end
