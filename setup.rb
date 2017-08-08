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


def schedule id
%Q<{
"id": "#{id}",
"hysteresis": 0.1,
"label": "#{id}",
"modes": {
"1": {
"min": 24,
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
end

i = 10;
IPS.each do |ip|
  @ip = ip
  rooms = api_get('rooms')
  rooms.each do |id, value|
    room = api_get("rooms/#{id}")
    room['devices'].keys.each do |id|
      device = api_get("devices/#{id}")
      if device['device info']['product type'] == 'HeatCoolArea'
        api_post('temperature/schedules', schedule("226#{i}"))
        device['schedule'] = "226#{i}"
        device.delete('actions info')
        device.delete('primary actions')
        device.delete('secondary actions')
        device.delete('settings')
        device.delete('cooling devices')
        api_post("devices", device.to_json)
        i+=1
      end
    end
  end
end