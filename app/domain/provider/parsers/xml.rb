# Purpose: Transforms XML response into domain data structure
# Responsibilities:
# - Parses XML data
# - Validates data structure
# - Handles parsing errors
# - Converts types (integers, decimals, booleans)
# - Returns Success/Failure results

module Domain
  module Provider
    module Parsers
      class Xml < Base
        def parse(content)
          doc = Nokogiri::XML(content)
          Success(
            events: parse_events(doc)
          )
        rescue Nokogiri::XML::SyntaxError => e
          Failure(ParsingError.new(e.message))
        end

        private

        def parse_events(doc)
          doc.xpath("//base_plan").map do |event_node|
            {
              external_id: event_node["base_plan_id"],
              title: event_node["title"],
              sell_mode: event_node["sell_mode"],
              slots: parse_slots(event_node)
            }
          end
        end

        def parse_slots(event_node)
          event_node.xpath(".//plan").map do |slot_node|
            {
              external_id: slot_node["plan_id"],
              starts_at: slot_node["plan_start_date"],
              ends_at: slot_node["plan_end_date"],
              sell_from: slot_node["sell_from"],
              sell_to: slot_node["sell_to"],
              zones: parse_zones(slot_node)
            }
          end
        end

        def parse_zones(slot_node)
          slot_node.xpath(".//zone").map do |zone_node|
            {
              external_id: zone_node["zone_id"],
              name: zone_node["name"],
              capacity: zone_node["capacity"].to_i,
              price: zone_node["price"].to_d,
              numbered: zone_node["numbered"] == "true"
            }
          end
        end
      end
    end
  end
end
