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

    devices = room['devices'].keys.map do |device_id|
      client.api_get("devices/#{device_id}")
    end

    heat_cool_areas = devices.select do |device|
      device['device info']['product type'] == 'HeatCoolArea'
    end

    states = heat_cool_areas.map do |hca|
      client.api_get("devices/#{hca['id']}/state")
    end

    puts"#{room_names[id]}: #{states.map{|state|"#{state['temperature']}[#{state['requested temperature']}]"}.join(', ')}"
  end

end
