# == Schema Information
#
# Table name: events
#
#  uuid              :uuid             not null
#  external_id       :string           not null
#  title             :string           not null
#  sell_mode         :string           not null
#  organizer_company_id :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Event < ApplicationRecord
  has_many :slots
  has_many :current_slots, -> { where(current: true) }, class_name: "Slot"

  validates :uuid, presence: true, uniqueness: { case_sensitive: false }
  validates :external_id, presence: true
  validates :title, presence: true
  validates :sell_mode, presence: true

  scope :available_in_range, ->(starts_at:, ends_at:) do
    where(sell_mode: "online")
      .joins(:current_slots)
      .where("slots.starts_at >= ? AND slots.ends_at <= ?", starts_at, ends_at)
      .preload(current_slots: :zones)
      .distinct
  end
end
