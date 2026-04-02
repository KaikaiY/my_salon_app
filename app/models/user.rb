class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, :role, presence: true

  belongs_to :company, optional: true
  enum :role, {
    admin: 0,
    therapist: 1,
    company_manager: 2,
    employee: 3
  }
end
