json.id event.id
json.uuid event.uuid
json.external_id event.external_id
json.title event.title
json.sell_mode event.sell_mode
json.organizer_company_id event.organizer_company_id
json.created_at event.created_at

json.slots event.slots.select { |slot| slot.starts_at >= Time.parse(params[:starts_at]) && slot.ends_at <= Time.parse(params[:ends_at]) } do |slot|
  json.id slot.id
  json.uuid slot.uuid
  json.external_id slot.external_id
  # json.event_id slot.event_id
  json.starts_at slot.starts_at
  json.ends_at slot.ends_at
  json.sell_from slot.sell_from
  json.sell_to slot.sell_to
  json.sold_out slot.sold_out
  json.created_at slot.created_at


  json.zones slot.zones do |zone|
    json.id zone.id
    json.uuid zone.uuid
    json.external_id zone.external_id
    # json.slot_id zone.slot_id
    json.name zone.name
    json.capacity zone.capacity
    json.price zone.price
    json.numbered zone.numbered
    json.created_at zone.created_at
  end
end
