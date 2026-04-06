FactoryBot.define do
  factory :invitation do
    sequence(:email) { |n| "invitee#{n}@example.com" }
    association :company
    association :invited_by, factory: %i[user admin]
    role { :employee }
    status { :pending }
    expires_at { 7.days.from_now }

    trait :accepted do
      status { :accepted }
      accepted_at { Time.current }
      association :user
    end

    trait :approved do
      status { :approved }
      accepted_at { 1.day.ago }
      approved_at { Time.current }
      association :user
    end

    after(:build) do |invitation|
      next if invitation.user.blank?

      invitation.user.company ||= invitation.company
      invitation.user.role = invitation.role if invitation.user.respond_to?(:role=)
    end

    trait :expired do
      status { :expired }
      expires_at { 1.day.ago }
    end

    trait :company_manager do
      role { :company_manager }
    end

    trait :therapist do
      role { :therapist }
    end
  end
end
