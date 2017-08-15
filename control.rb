require 'json'
require 'erb'
require_relative 'lib/multi_client'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']
multi_client = MultiClient.new(IPS)

room_names = JSON.parse(File.read('roomnames.json'))

room_id = room_names.key(ARGV[0])
temperature = Integer(ARGV[1])

schedule = ERB.new(File.read('lib/templates/schedule.erb'))

client = multi_client.client_for_id('rooms', room_id)

room = client.api_get("rooms/#{room_id}")
room['devices'].keys.each do |device_id|
  device = client.api_get("devices/#{device_id}")
  if device['device info']['product type'] == 'HeatCoolArea'
    schedule_id = device['schedule']
    client.api_post('temperature/schedules', schedule.result(binding))
  end
end
