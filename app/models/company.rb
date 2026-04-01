class Company < ApplicationRecord
  has_many :users

  validates :company_name, :email, :phone, presence: true
end
