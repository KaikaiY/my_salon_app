class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, :role, presence: true

  belongs_to :company, optional: true
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :invited_by_id
  has_one :invitation, dependent: :nullify
  has_many :created_treatment_days, class_name: "TreatmentDay", foreign_key: :created_by_id
  has_many :assigned_treatment_days, class_name: "TreatmentDay", foreign_key: :therapist_id
  has_many :reservations

  enum :role, {
    admin: 0,
    therapist: 1,
    company_manager: 2,
    employee: 3
  }

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :inactive
  end
end
