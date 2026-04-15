FactoryBot.define do
  factory :reservation do
    status { :reserved }
    cancel_reason { nil }
    note { 'テスト予約メモ' }
    user
    time_slot

    trait :cancelled do
      status { :cancelled }
      cancel_reason { 'キャンセル理由' }
    end

    trait :completed do
      status { :completed }
    end
  end
end
