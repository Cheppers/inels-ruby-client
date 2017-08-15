require 'rest-client'
require 'json'
require_relative 'lib/multi_client'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']
multi_client = MultiClient.new(IPS)

room_names = JSON.parse(File.read('roomnames.json'))

multi_client.clients.each do |client|
  rooms = client.api_get('rooms')
  rooms.keys.each do |id| 
    room = client.api_get("rooms/#{id}")
    temperature = room['devices'].keys.select do |id|
      device = client.api_get("devices/#{id}")
      device['device info']['product type'] == 'HeatCoolArea'
    end.map do |id|
      device_status = client.api_get("devices/#{id}/state")
      "#{device_status['temperature']}[#{device_status['requested temperature']}]"
    end.compact
  
    puts"#{room_names[id]}: #{temperature.join(', ')}"
  end
end
