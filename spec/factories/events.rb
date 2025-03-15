FactoryBot.define do
  factory :event do
    uuid { SecureRandom.uuid }
    sequence(:external_id) { |n| "event_#{n}" }
    title { "Some Event" }
    sell_mode { "online" }
    organizer_company_id { nil }
  end
end
