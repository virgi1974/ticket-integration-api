require "rails_helper"

RSpec.describe Events::CacheHitStrategy do
  describe "#execute" do
    let(:cached_json) { { data: [], meta: { pagination: {} } }.to_json }
    let(:strategy) { described_class.new(cached_json) }

    it "returns the cached JSON with from_cache flag" do
      result = strategy.execute
      expect(result[:json]).to eq(cached_json)
      expect(result[:from_cache]).to be true
    end

    it "logs a cache hit message" do
      expect(Rails.logger).to receive(:info).with("CACHE HIT: Serving events from cache")
      strategy.execute
    end
  end
end
