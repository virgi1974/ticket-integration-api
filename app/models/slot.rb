# == Schema Information
#
# Table name: slots
#
#  id          :integer          not null, primary key
#  uuid        :uuid             not null
#  external_id :string           not null
#  event_id    :integer          not null
#  starts_at   :datetime         not null
#  ends_at     :datetime         not null
#  sell_from   :datetime         not null
#  sell_to     :datetime         not null
#  sold_out    :boolean          default(false), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Slot < ApplicationRecord
  has_many :zones
  belongs_to :event

  validates :uuid, presence: true, uniqueness: { case_sensitive: false }
  validates :external_id, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :sell_from, presence: true
  validates :sell_to, presence: true
end
