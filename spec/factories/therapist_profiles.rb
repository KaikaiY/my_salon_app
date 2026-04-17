FactoryBot.define do
  factory :therapist_profile do
    association :user, factory: %i[user therapist]
    bio { '施術者の自己紹介です。' }
    specialty { 'リラクゼーション' }
    career { '経験5年。サロン勤務経験あり。' }
    published { false }

    trait :published do
      published { true }
    end
  end
end
