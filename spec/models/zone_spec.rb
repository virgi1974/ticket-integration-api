require 'rails_helper'

RSpec.describe Zone, type: :model do
  describe "associations" do
    it { should belong_to(:slot) }
  end
end
