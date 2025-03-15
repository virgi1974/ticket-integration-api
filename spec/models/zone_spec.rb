require "rails_helper"

RSpec.describe Zone, type: :model do
  subject(:zone) { build(:zone) }

  describe "associations" do
    it { should belong_to(:slot) }
  end

  describe "validations" do
    it { should validate_presence_of(:uuid) }
    it { should validate_uniqueness_of(:uuid).case_insensitive }
    it { should validate_presence_of(:external_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end
end
