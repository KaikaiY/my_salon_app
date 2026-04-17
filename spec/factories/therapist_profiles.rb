FactoryBot.define do
  factory :therapist_profile do
    user { nil }
    bio { "MyText" }
    specialty { "MyString" }
    career { "MyText" }
    published { false }
  end
end
