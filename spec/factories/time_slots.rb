FactoryBot.define do
  factory :time_slot do
    start_time { '10:00' }
    end_time { '11:00' }
    treatment_day
  end
end
