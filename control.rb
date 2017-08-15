require 'json'
require_relative 'lib/controller'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']
controller = Controller.new(IPS)

room_names = JSON.parse(File.read('roomnames.json'))

room_id = room_names.key(ARGV[0])
temperature = Integer(ARGV[1])

controller.set_temperature room_id, temperature


