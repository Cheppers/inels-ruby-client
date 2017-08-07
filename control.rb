require 'rest-client'
require 'json'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']

def api_get path
  response = RestClient.get "http://#{@ip}/api/#{path}"
  JSON.parse(response.body)
end

def api_post path, payload
  response = RestClient.post "http://#{@ip}/api/#{path}", payload, {content_type: :json, accept: :json}
  response.body
end

room_names = JSON.parse(File.read('roomnames.json'))


room_name = ARGV[0]
temperature = Integer(ARGV[1])

schedule = %Q<{
"id": "226#{temperature}",
"hysteresis": 0.1,
"label": "k3idoprog#{temperature}",
"modes": {
"1": {
"min": #{temperature},
"max": 35
},
"2": {
"min": 20,
"max": 35
},
"3": {
"min": 20,
"max": 35
},
"4": {
"min": 28,
"max": 35
}
},
"schedule": {
"monday": [
{
"duration": 1440,
"mode": 1
}
],
"tuesday": [
{
"duration": 1440,
"mode": 1
}
],
"wednesday": [
{
"duration": 1440,
"mode": 1
}
],
"thursday": [
{
"duration": 1440,
"mode": 1
}
],
"friday": [
{
"duration": 1440,
"mode": 1
}
],
"saturday": [
{
"duration": 1440,
"mode": 1
}
],
"sunday": [
{
"duration": 1440,
"mode": 1
}
]
}
}>

IPS.each do |ip|
  @ip = ip
  rooms = api_get('rooms')
  rooms.each do |id, value|
    room = api_get("rooms/#{id}")
    if room_names[room['room info']['label']] == room_name
      api_post('temperature/schedules', schedule)
      room['devices'].keys.each do |id|
        device = api_get("devices/#{id}")
        if device['device info']['product type'] == 'HeatCoolArea'
          device['schedule'] = "226#{temperature}"
          device.delete('actions info')
          device.delete('primary actions')
          device.delete('secondary actions')
          device.delete('settings')
          device.delete('cooling devices')
          api_post("devices", device.to_json)
        end
      end
    end
  end
end