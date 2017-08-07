require 'rest-client'
require 'json'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']

def api_get path
  response = RestClient.get "http://#{@ip}/api/#{path}"
  JSON.parse(response.body)
end

room_names = JSON.parse(File.read('roomnames.json'))

IPS.each do |ip|
  @ip = ip
  rooms = api_get('rooms')
  rooms.each do |id, value| 
    room = api_get("rooms/#{id}")
    temperature = room['devices'].keys.select do |id|
      device = api_get("devices/#{id}")
      device['device info']['product type'] == 'HeatCoolArea'
    end.map do |id|
      device_status = api_get("devices/#{id}/state")
      "#{device_status['temperature']}[#{device_status['requested temperature']}]"
    end.compact
  
    puts"#{room_names[room['room info']['label']]}: #{temperature.join(', ')}"
  end
end
