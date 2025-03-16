json.meta do
  json.pagination @pagination
end

json.data do
  json.array! @events do |event|
    json.partial! "event", event: event
  end
end
