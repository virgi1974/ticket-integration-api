# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Clear existing data (uncomment if needed)
# Event.destroy_all

# Event categories with corresponding titles
event_categories = {
  "music" => [
    "Rock Festival 2023",
    "Jazz Night Under the Stars",
    "Symphony Orchestra Concert",
    "Indie Band Showcase",
    "Electronic Music Festival",
    "Classical Piano Recital",
    "Hip Hop Live Show",
    "Opera Gala Evening",
    "Country Music Festival",
    "Reggae Beach Party"
  ],
  "sports" => [
    "Premier League Match",
    "Tennis Championship Finals",
    "Basketball Tournament",
    "Olympic Swimming Qualifiers",
    "Football Derby",
    "Marathon Race",
    "MMA Championship Fight",
    "Golf Tournament",
    "Cricket World Cup Match",
    "Cycling Race"
  ],
  "museum visit" => [
    "Modern Art Exhibition",
    "Natural History Special Tour",
    "Ancient Civilizations Exhibit",
    "Photography Gallery Opening",
    "Science Museum Night Tour",
    "Historical Artifacts Showcase",
    "Maritime Museum Tour",
    "Space Exploration Exhibition",
    "Renaissance Art Collection",
    "Indigenous Culture Exhibit"
  ],
  "family" => [
    "Disney on Ice",
    "Children's Theater Show",
    "Family Fun Fair",
    "Magic Show for Kids",
    "Circus Spectacular",
    "Puppet Show Festival",
    "Animal Park Family Day",
    "Interactive Science Experience",
    "Storytelling Adventure",
    "Family Movie Night"
  ]
}

# Create events with slots and zones
puts "Creating events, slots, and zones..."

30.times do |i|
  # Select random category and title
  category = event_categories.keys.sample
  title = event_categories[category].sample

  # Create event
  event = Event.find_or_create_by(uuid: SecureRandom.uuid) do |e|
    e.external_id = (1000 + i).to_s
    e.title = title
    e.category = category
    e.sell_mode = ["online", "offline"].sample
    e.organizer_company_id = ["ABC123", "XYZ456", "DEF789", nil].sample
  end

  puts "Created event: #{event.title} (#{event.category})"

  # Create 1-3 slots per event
  rand(1..3).times do |j|
    # Generate dates
    base_date = Time.now + rand(1..60).days
    starts_at = base_date + rand(10..20).hours
    ends_at = starts_at + rand(1..4).hours
    sell_from = base_date - rand(30).days
    sell_to = starts_at - 1.hour

    # Create slot - all slots are current
    slot = Slot.find_or_create_by(uuid: SecureRandom.uuid) do |s|
      s.external_id = "#{event.external_id}-#{j}"
      s.event = event
      s.starts_at = starts_at
      s.ends_at = ends_at
      s.sell_from = sell_from
      s.sell_to = sell_to
      s.sold_out = [true, false, false, false, false].sample  # 20% chance of being sold out
      s.current = true  # All slots are current
    end

    # Create 1-4 zones per slot
    rand(1..4).times do |k|
      zone_types = {
        "music" => ["VIP Area", "Standing Area", "Seated Area", "Balcony", "Front Row"],
        "sports" => ["Home Fans", "Away Fans", "VIP Box", "Central Seating", "Premium Seats"],
        "museum visit" => ["Main Exhibition", "Special Collection", "Guided Tour", "Interactive Area"],
        "family" => ["Family Section", "Kids Zone", "VIP Experience", "General Admission"]
      }

      price_ranges = {
        "music" => [15.0, 50.0],
        "sports" => [20.0, 100.0],
        "museum visit" => [8.0, 25.0],
        "family" => [10.0, 35.0]
      }

      zone_names = zone_types[category]
      price_range = price_ranges[category]

      Zone.find_or_create_by(uuid: SecureRandom.uuid) do |z|
        z.external_id = "#{slot.external_id}-#{k}"
        z.slot = slot
        z.name = zone_names.sample
        z.capacity = rand(50..500)
        z.price = rand(price_range[0]..price_range[1]).round(2)
        z.numbered = [true, false].sample
      end
    end
  end
end

puts "Seeding completed successfully!"
