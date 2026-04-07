FactoryBot.define do
  factory :company do
    company_name { Faker::Company.unique.name.truncate(255) }
    email { Faker::Internet.unique.email }
    phone { Faker::Number.number(digits: 10) }
    active { true }
  end
end
