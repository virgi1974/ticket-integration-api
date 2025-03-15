require "rails_helper"

RSpec.describe Slot, type: :model do
  subject(:slot) { build(:slot) }

  describe "associations" do
    it { should have_many(:zones) }
    it { should belong_to(:event) }
  end

  describe "validations" do
    it { should validate_presence_of(:uuid) }
    it { should validate_uniqueness_of(:uuid).case_insensitive }
    it { should validate_presence_of(:external_id) }
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:sell_from) }
    it { should validate_presence_of(:sell_to) }
  end
end
