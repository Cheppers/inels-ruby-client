#!/usr/bin/env ruby

require 'thor'
require 'json'
require_relative 'lib/controller'

IPS = ['192.168.1.30', '192.168.1.31', '192.168.1.32']
ROOM_NAMES = JSON.parse(File.read('roomnames.json'))

class InelsCLI < Thor

  desc 'set-temperature', 'Sets room temperature'
  def set_temperature room_name, temperature
    Inels::Controller.new(IPS).set_temperature(ROOM_NAMES.key(room_name), Integer(temperature))
  end

  desc 'get-temperature', 'Gets room temperature'
  def get_temperature room_name
    Inels::Controller.new(IPS).get_states(ROOM_NAMES.key(room_name)).each do |hcl_id, state|
      puts "#{hcl_id}: #{state['temperature']}[#{state['requested temperature']}]"
    end
  end

  desc 'get-all-temperature', 'Gets all room temperature'
  def get_all_temperature
    Inels::Controller.new(IPS).get_all_states.each do |id, states|
      puts "#{ROOM_NAMES[id]}: #{states.values.map{|state|"#{state['temperature']}[#{state['requested temperature']}]"}.join(', ')}"
    end
  end
end

InelsCLI.start