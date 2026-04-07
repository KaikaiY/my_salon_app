class TreatmentDay < ApplicationRecord
  belongs_to :company
  belongs_to :therapist, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User"

  enum :booking_source, {
    app: 0,
    phone: 1,
    email: 2,
    admin_input: 3
  }

  enum :status, {
    pending: 0,
    confirmed: 1,
    cancelled: 2
  }

  validates :date, :booking_source, :status, presence: true
end
