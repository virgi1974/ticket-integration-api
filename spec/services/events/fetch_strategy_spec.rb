require "rails_helper"

RSpec.describe Events::FetchStrategy do
  describe ".for" do
    let(:date_range) { instance_double("DateRange", starts_at: Time.parse("2023-01-01"), ends_at: Time.parse("2023-12-31")) }
    let(:page) { 1 }
    let(:per_page) { 20 }
    let(:cache_key) { "events:data:1672531200_1704067200:page_1:per_20" }

    before do
      allow(EventCacheService).to receive(:generate_events_key).and_return(cache_key)
    end

    context "when cache hit" do
      let(:cached_json) { { data: [], meta: { pagination: {} } }.to_json }

      before do
        allow(EventCacheService).to receive(:get).with(cache_key).and_return(cached_json)
      end

      it "returns a CacheHitStrategy" do
        strategy = described_class.for(date_range, page, per_page, cache_key)
        expect(strategy).to be_a(Events::CacheHitStrategy)
      end
    end

    context "when cache miss" do
      before do
        allow(EventCacheService).to receive(:get).with(cache_key).and_return(nil)
      end

      it "returns a CacheMissStrategy" do
        strategy = described_class.for(date_range, page, per_page, cache_key)
        expect(strategy).to be_a(Events::CacheMissStrategy)
      end
    end
  end
end
