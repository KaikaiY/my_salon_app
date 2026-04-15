FactoryBot.define do
  factory :treatment_day do
    date { Date.current }
    booking_source { :app }
    status { :pending }
    note { 'テストメモ' }
    company
    association :created_by, factory: %i[user admin]
    association :therapist, factory: %i[user therapist]
  end
end
