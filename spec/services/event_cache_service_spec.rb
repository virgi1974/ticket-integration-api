require "rails_helper"

RSpec.describe EventCacheService do
  let(:redis) { instance_double("Redis") }
  let(:cache_key) { "events:data:1234567890_1234567899:page_1:per_20" }
  let(:data) { { events: [1, 2, 3], meta: { total: 3 } } }
  let(:json_data) { data.to_json }

  before do
    allow(RedisConnection).to receive(:connection).and_return(redis)
  end

  describe ".get" do
    context "when Redis is available" do
      it "returns cached data when it exists" do
        allow(redis).to receive(:get).with(cache_key).and_return(json_data)
        allow(redis).to receive(:zadd)

        result = described_class.get(cache_key)
        expect(result).to eq(json_data)
      end

      it "updates LRU tracking when cache is hit" do
        allow(redis).to receive(:get).with(cache_key).and_return(json_data)
        expect(redis).to receive(:zadd).with("events:lru", kind_of(Integer), cache_key)

        described_class.get(cache_key)
      end

      it "returns nil when cache miss" do
        allow(redis).to receive(:get).with(cache_key).and_return(nil)

        result = described_class.get(cache_key)
        expect(result).to be_nil
      end
    end

    context "when Redis is unavailable" do
      before do
        allow(RedisConnection).to receive(:connection).and_return(nil)
      end

      it "returns nil" do
        result = described_class.get(cache_key)
        expect(result).to be_nil
      end
    end

    context "when Redis raises an error" do
      it "logs the error and returns nil" do
        allow(redis).to receive(:get).and_raise(Redis::BaseError.new("connection error"))
        allow(Rails.logger).to receive(:error)

        result = described_class.get(cache_key)

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Redis error during cache fetch/)
      end
    end
  end

  describe ".set" do
    context "when Redis is available" do
      before do
        allow(redis).to receive(:setex)
        allow(redis).to receive(:zadd)
        allow(redis).to receive(:zcard).and_return(50)
      end

      it "stores the data with TTL" do
        expect(redis).to receive(:setex).with(cache_key, described_class::DEFAULT_TTL, json_data)

        described_class.set(cache_key, data)
      end

      it "adds to LRU tracking" do
        expect(redis).to receive(:zadd).with("events:lru", kind_of(Integer), cache_key)

        described_class.set(cache_key, data)
      end

      it "accepts string data directly" do
        expect(redis).to receive(:setex).with(cache_key, described_class::DEFAULT_TTL, json_data)

        described_class.set(cache_key, json_data)
      end

      it "accepts custom TTL" do
        custom_ttl = 30.minutes.to_i
        expect(redis).to receive(:setex).with(cache_key, custom_ttl, json_data)

        described_class.set(cache_key, data, custom_ttl)
      end
    end

    context "when cache needs pruning" do
      before do
        allow(redis).to receive(:setex)
        allow(redis).to receive(:zadd)
        allow(redis).to receive(:zcard).and_return(described_class::MAX_CACHE_ENTRIES + 1)
        allow(redis).to receive(:zrange).and_return(["old_key"])
        allow(redis).to receive(:zrem)
        allow(redis).to receive(:del)
      end

      it "prunes old entries" do
        expect(redis).to receive(:zrange).with("events:lru", 0, -described_class::MAX_CACHE_ENTRIES)
        expect(redis).to receive(:zrem).with("events:lru", ["old_key"])
        expect(redis).to receive(:del).with(["old_key"])

        described_class.set(cache_key, data)
      end
    end

    context "when Redis is unavailable" do
      before do
        allow(RedisConnection).to receive(:connection).and_return(nil)
      end

      it "returns nil without error" do
        result = described_class.set(cache_key, data)
        expect(result).to be_nil
      end
    end

    context "when Redis raises an error" do
      it "logs the error and continues" do
        allow(redis).to receive(:setex).and_raise(Redis::BaseError.new("connection error"))
        allow(Rails.logger).to receive(:error)

        result = described_class.set(cache_key, data)

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Redis error during cache storage/)
      end
    end
  end

  describe ".generate_events_key" do
    let(:starts_at) { Time.new(2023, 1, 1) }
    let(:ends_at) { Time.new(2023, 12, 31) }

    it "generates key with pagination" do
      key = described_class.generate_events_key(starts_at, ends_at, 1, 20)
      expect(key).to eq("events:data:#{starts_at.to_i}_#{ends_at.to_i}:page_1:per_20")
    end

    it "generates key without pagination" do
      key = described_class.generate_events_key(starts_at, ends_at)
      expect(key).to eq("events:data:#{starts_at.to_i}_#{ends_at.to_i}")
    end
  end

  describe ".invalidate_all" do
    context "when Redis is available" do
      it "removes all event cache keys" do
        allow(redis).to receive(:keys).with("events:*").and_return(["key1", "key2"])
        expect(redis).to receive(:del).with(["key1", "key2"])
        expect(redis).to receive(:del).with("events:lru")

        described_class.invalidate_all
      end

      it "handles no existing keys" do
        allow(redis).to receive(:keys).with("events:*").and_return([])
        expect(redis).to receive(:del).with("events:lru")

        described_class.invalidate_all
      end
    end

    context "when Redis is unavailable" do
      before do
        allow(RedisConnection).to receive(:connection).and_return(nil)
      end

      it "returns without error" do
        expect { described_class.invalidate_all }.not_to raise_error
      end
    end
  end
end
