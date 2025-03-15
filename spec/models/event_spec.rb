require "rails_helper"

RSpec.describe Event, type: :model do
  subject(:event) { build(:event) }

  describe "associations" do
    it { should have_many(:slots) }
  end

  describe "validations" do
    it { should validate_presence_of(:uuid) }
    it { should validate_uniqueness_of(:uuid).case_insensitive }
    it { should validate_presence_of(:external_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:sell_mode) }
  end
end
