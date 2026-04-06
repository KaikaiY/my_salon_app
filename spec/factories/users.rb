FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { password }
    name { Faker::Name.name }
    role { :employee }
    active { true }
    company

    trait :admin do
      role { :admin }
      company { nil }
    end

    trait :therapist do
      role { :therapist }
      company { nil }
    end

    trait :company_manager do
      role { :company_manager }
    end

    trait :inactive do
      active { false }
    end
  end
end
