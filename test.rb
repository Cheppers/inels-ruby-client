require 'rest-client'
require 'json'
require 'erb'
require_relative 'lib/client'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']

room_names = JSON.parse(File.read('roomnames.json'))

IPS.each do |ip|
  client = Client.new(ip)
  rooms = client.api_get('rooms')
  p rooms.keys.include?("29106")
end