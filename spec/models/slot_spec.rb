require 'rails_helper'

RSpec.describe Slot, type: :model do
  describe "associations" do
    it { should have_many(:zones) }
    it { should belong_to(:event) }
  end
end
