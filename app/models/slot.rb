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
end
