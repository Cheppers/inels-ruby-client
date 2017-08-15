require 'json'
require_relative 'lib/controller'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']
controller = Controller.new(IPS)

room_names = JSON.parse(File.read('roomnames.json'))

room_states = controller.get_all_states

room_states.each do |id, states|
  puts"#{room_names[id]}: #{states.map{|state|"#{state['temperature']}[#{state['requested temperature']}]"}.join(', ')}"
end