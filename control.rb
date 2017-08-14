require 'rest-client'
require 'json'
require 'erb'
require_relative 'lib/client'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']

room_names = JSON.parse(File.read('roomnames.json'))


room_name = ARGV[0]
temperature = Integer(ARGV[1])

schedule = ERB.new(File.read('lib/templates/schedule.erb'))

IPS.each do |ip|
  client = Client.new(ip)
  rooms = client.api_get('rooms')
  rooms.keys.each do |id|
    room = client.api_get("rooms/#{id}")
    if room_names[room['room info']['label']] == room_name
      room['devices'].keys.each do |id|
        device = client.api_get("devices/#{id}")
        if device['device info']['product type'] == 'HeatCoolArea'
          schedule_id = device['schedule']
          client.api_post('temperature/schedules', schedule.result(binding))
        end
      end
    end
  end
end