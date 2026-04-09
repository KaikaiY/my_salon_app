class Invitation < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :invited_by, class_name: "User"

  enum :role, {
    admin: 0,
    therapist: 1,
    company_manager: 2,
    employee: 3
  }

  enum :status, {
    pending: 0,
    accepted: 1,
    approved: 2,
    expired: 3
  }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_validation :assign_token, on: :create
  before_validation :set_default_expiration, on: :create

  validates :email, presence: true, 
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :token, presence: true, uniqueness: true
  validates :role, presence: true
  validates :expires_at, presence: true
  validate :expires_at_in_future
  validate :admin_role_cannot_be_selected
  validates :company, presence: true, if: :company_required?

  

  scope :recent_first, -> { order(created_at: :desc) }

  def available_for_signup?
    pending? && expires_at.future?
  end

  def mark_as_expired_if_needed!
    return unless pending? && expires_at.past?

    update!(status: :expired)
  end

  private

  def assign_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_default_expiration
    self.expires_at ||= 7.days.from_now
  end

  def expires_at_in_future
    if expires_at.present? && expires_at < Time.current
      errors.add(:expires_at, "は過去の日付です")
    end
  end

  def admin_role_cannot_be_selected
    return unless admin?

    errors.add(:role, "は指定できません")
  end

  def company_required?
    company_manager? || employee?
  end

  

end
