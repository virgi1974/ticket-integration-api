FactoryBot.define do
  factory :zone do
    uuid { SecureRandom.uuid }
    sequence(:external_id) { |n| "zone_#{n}" }
    sequence(:name) { |n| "Zone #{n}" }
    capacity { 100 }
    price { 29.99 }
    numbered { false }
    association :slot
  end
end
