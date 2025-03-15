# == Schema Information
#
# Table name: zones
#
#  id          :integer          not null, primary key
#  uuid        :uuid             not null
#  external_id :string           not null
#  slot_id     :integer          not null
#  name        :string           not null
#  capacity    :integer          not null
#  price       :decimal(10, 2)   not null
#  numbered    :boolean          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Zone < ApplicationRecord
  belongs_to :slot

  validates :uuid, presence: true, uniqueness: { case_sensitive: false }
  validates :external_id, presence: true
  validates :name, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
