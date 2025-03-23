json.id event.id
json.uuid event.uuid
json.external_id event.external_id
json.title event.title
json.sell_mode event.sell_mode
json.category event.category
json.organizer_company_id event.organizer_company_id
json.created_at event.created_at

json.slots event.current_slots do |slot|
  json.partial! "api/v1/slots/slot", slot: slot
end
