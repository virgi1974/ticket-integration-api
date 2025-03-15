FactoryBot.define do
  factory :slot do
    uuid { SecureRandom.uuid }
    sequence(:external_id) { |n| "slot_#{n}" }
    association :event
    starts_at { Time.current }
    ends_at { 1.hour.from_now }
    sell_from { Time.current }
    sell_to { 2.hours.from_now }
    sold_out { false }
  end
end
