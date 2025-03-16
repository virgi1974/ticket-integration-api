json.id slot.id
json.uuid slot.uuid
json.external_id slot.external_id
json.starts_at slot.starts_at
json.ends_at slot.ends_at
json.sell_from slot.sell_from
json.sell_to slot.sell_to
json.sold_out slot.sold_out
json.created_at slot.created_at

json.zones slot.zones do |zone|
  json.partial! "api/v1/zones/zone", zone: zone
end
