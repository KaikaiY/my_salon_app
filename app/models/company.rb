class Company < ApplicationRecord
  has_many :users
  has_many :invitations, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :company_name, presence: true, length: { maximum: 255 }
  validates :phone, presence: true, format: { with: /\A\d{10,11}\z/, message: 'は半角数字で入力してください' }
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
end
