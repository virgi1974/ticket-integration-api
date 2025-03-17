json.meta do
  json.pagination @pagination
end

json.data do
  json.array! @events do |event|
    json.partial! "api/v1/events/event", event: event
  end
end
