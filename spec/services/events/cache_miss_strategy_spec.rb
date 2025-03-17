require "rails_helper"

RSpec.describe Events::CacheMissStrategy do
  describe "#execute" do
    let(:date_range) { instance_double("DateRange", starts_at: Time.parse("2023-01-01"), ends_at: Time.parse("2023-12-31")) }
    let(:page) { 1 }
    let(:per_page) { 20 }
    let(:cache_key) { "events:data:1672531200_1704067200:page_1:per_20" }
    let(:strategy) { described_class.new(date_range, page, per_page, cache_key) }

    let(:events) { create_list(:event, 3) }
    let(:events_relation) { Event.where(id: events.map(&:id)) }

    before do
      allow(Event).to receive(:available_in_range).and_return(events_relation)
      allow(events_relation).to receive(:limit).and_return(events_relation)
      allow(events_relation).to receive(:offset).and_return(events_relation)
      allow(events_relation).to receive(:count).and_return(3)
    end

    it "returns events and pagination data with from_cache flag" do
      result = strategy.execute

      expect(result[:events]).to eq(events_relation)
      expect(result[:pagination]).to include(
        current_page: page,
        per_page: per_page,
        total_count: 3,
        total_pages: 1
      )
      expect(result[:from_cache]).to be false
    end

    it "logs a cache miss message" do
      expect(Rails.logger).to receive(:info).with("CACHE MISS: Fetching events from database")
      strategy.execute
    end

    it "queries the database with correct parameters" do
      expect(Event).to receive(:available_in_range).with(
        starts_at: date_range.starts_at,
        ends_at: date_range.ends_at
      )

      strategy.execute
    end

    it "applies correct pagination" do
      expect(events_relation).to receive(:limit).with(per_page)
      expect(events_relation).to receive(:offset).with(0) # (page-1)*per_page = 0

      strategy.execute
    end
  end
end
