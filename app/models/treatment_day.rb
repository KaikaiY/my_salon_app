class TreatmentDay < ApplicationRecord
  BOOKING_SOURCE_LABELS = {
    app: "アプリ",
    phone: "電話",
    email: "メール",
    admin_input: "管理者入力"
  }.freeze

  STATUS_LABELS = {
    pending: "確認待ち",
    confirmed: "確定",
    cancelled: "中止"
  }.freeze

  belongs_to :company
  belongs_to :therapist, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User"
  has_many :time_slots

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

  def human_booking_source
    BOOKING_SOURCE_LABELS[booking_source.to_sym]
  end

  def human_status
    STATUS_LABELS[status.to_sym]
  end

  def self.booking_source_options
    booking_sources.keys.map { |source| [BOOKING_SOURCE_LABELS[source.to_sym], source] }
  end

  def self.status_options
    statuses.keys.map { |status| [STATUS_LABELS[status.to_sym], status] }
  end
end
