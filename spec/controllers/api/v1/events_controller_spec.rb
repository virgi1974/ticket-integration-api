require "rails_helper"

RSpec.describe Api::V1::EventsController, type: :controller do
  describe "GET #index" do
    let(:starts_at) { "2023-01-01" }
    let(:ends_at) { "2023-12-31" }
    let(:page) { 1 }
    let(:per_page) { 20 }

    # Mock data
    let(:events) { create_list(:event, 3) }
    let(:pagination) { { current_page: page, per_page: per_page, total_count: 3, total_pages: 1 } }
    let(:json_response) { { data: events, meta: { pagination: pagination } }.to_json }

    # Create a real DateRange object like the controller does
    let(:date_range) do
      DateRange.new(
        starts_at: starts_at,
        ends_at: ends_at
      )
    end

    # Get the actual cache key that will be used
    let(:cache_key) do
      EventCacheService.generate_events_key(
        date_range.starts_at,
        date_range.ends_at,
        page,
        per_page
      )
    end

    context "when cache miss" do
      before do
        # Ensure cache is empty - use a flexible matcher for the cache key
        allow(EventCacheService).to receive(:get).and_return(nil)

        # Mock database query - use a double for the relation
        events_relation = double("EventsRelation")
        paginated_relation = double("PaginatedRelation")

        allow(Event).to receive(:available_in_range).and_return(events_relation)
        allow(events_relation).to receive(:limit).and_return(paginated_relation)
        allow(paginated_relation).to receive(:offset).and_return(events)
        allow(events_relation).to receive(:count).and_return(3)

        # Mock cache storage - use a flexible matcher for the cache key
        allow(EventCacheService).to receive(:set).and_return(json_response)

        # Mock render_to_string
        allow(controller).to receive(:render_to_string).and_return(json_response)

        get :index, params: { starts_at: starts_at, ends_at: ends_at, page: page, per_page: per_page }, format: :json
      end

      it "queries the database" do
        expect(Event).to have_received(:available_in_range)
      end

      it "stores the result in cache" do
        expect(EventCacheService).to have_received(:set)
      end

      it "returns successful response" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when cache hit" do
      before do
        # Mock cache hit - use a flexible matcher for the cache key
        allow(EventCacheService).to receive(:get).and_return(json_response)

        # Ensure database is not queried
        allow(Event).to receive(:available_in_range).never

        get :index, params: { starts_at: starts_at, ends_at: ends_at, page: page, per_page: per_page }, format: :json
      end

      it "does not query the database" do
        expect(Event).not_to have_received(:available_in_range)
      end

      it "returns cached response" do
        expect(response).to have_http_status(:success)
        expect(response.body).to eq(json_response)
      end
    end

    context "with invalid date parameters" do
      it "returns bad request for invalid date format" do
        # Use the actual error that would be raised
        allow_any_instance_of(DateRange).to receive(:initialize).and_raise(Dry::Struct::Error)

        get :index, params: { starts_at: "invalid-date", ends_at: ends_at }, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it "returns bad request for invalid date range" do
        # Make the date range validation fail
        allow_any_instance_of(DateRange).to receive(:valid?).and_return(false)
        allow_any_instance_of(DateRange).to receive(:errors).and_return([ "starts_at must be before ends_at" ])

        get :index, params: { starts_at: ends_at, ends_at: starts_at }, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with pagination parameters" do
      let(:large_dataset) { double("LargeDataset") }
      let(:page2_set) { double("Page2Set") }
      let(:page1_set) { double("Page1Set") }

      before do
        # Setup for a larger dataset
        allow(EventCacheService).to receive(:get).and_return(nil)
        allow(Event).to receive(:available_in_range).and_return(large_dataset)
        allow(large_dataset).to receive(:count).and_return(100)

        # Mock render_to_string
        allow(controller).to receive(:render_to_string).and_return(json_response)
      end

      it "returns the correct page of results" do
        # Test page 2 with 10 per page
        allow(large_dataset).to receive(:limit).with(10).and_return(page2_set)
        allow(page2_set).to receive(:offset).with(10).and_return(events)

        get :index, params: { starts_at: starts_at, ends_at: ends_at, page: 2, per_page: 10 }, format: :json

        # Verify correct offset was used
        expect(page2_set).to have_received(:offset).with(10)
        expect(response).to have_http_status(:success)
      end

      it "handles edge case pagination values" do
        # Test with page=0 (should be treated as page 1)
        allow(large_dataset).to receive(:limit).with(20).and_return(page1_set)
        allow(page1_set).to receive(:offset).with(0).and_return(events)

        get :index, params: { starts_at: starts_at, ends_at: ends_at, page: 0 }, format: :json

        # Should be treated as page 1 (offset 0)
        expect(page1_set).to have_received(:offset).with(0)
        expect(response).to have_http_status(:success)
      end
    end

    context "when Redis is unavailable" do
      before do
        # Mock Redis connection to be nil (simulating connection failure)
        allow(RedisConnection).to receive(:connection).and_return(nil)

        # Mock database query
        events_relation = double("EventsRelation")
        paginated_relation = double("PaginatedRelation")

        allow(Event).to receive(:available_in_range).and_return(events_relation)
        allow(events_relation).to receive(:limit).and_return(paginated_relation)
        allow(paginated_relation).to receive(:offset).and_return(events)
        allow(events_relation).to receive(:count).and_return(3)

        # Mock render_to_string
        allow(controller).to receive(:render_to_string).and_return(json_response)

        get :index, params: { starts_at: starts_at, ends_at: ends_at }, format: :json
      end

      it "still returns results when Redis is down" do
        expect(response).to have_http_status(:success)
        expect(Event).to have_received(:available_in_range)
      end
    end

    context "with response format" do
      render_views

      before do
        # Setup for checking response format
        allow(EventCacheService).to receive(:get).and_return(nil)

        # Create real Event objects
        create_list(:event, 3)

        # Get a real ActiveRecord::Relation
        events_relation = Event.all

        # Mock the available_in_range method to return this relation
        allow(Event).to receive(:available_in_range).and_return(events_relation)

        # Request JSON format explicitly
        get :index, params: { starts_at: starts_at, ends_at: ends_at }, format: :json
      end

      it "returns JSON with the correct structure" do
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        expect(json).to have_key("data")
        expect(json).to have_key("meta")
        expect(json["meta"]).to have_key("pagination")
      end
    end
  end
end
