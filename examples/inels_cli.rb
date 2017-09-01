#!/usr/bin/env ruby

require 'thor'
require 'yaml'
require_relative '../lib/inels'

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config.yml')))

class InelsCLI < Thor
  desc 'set-temperature', 'Sets room temperature'
  def set_temperature room_name, temperature
    Inels::Controller.new(CONFIG['ips']).set_temperature(CONFIG['room names'].key(room_name), Integer(temperature))
  end

  desc 'get-temperature', 'Gets room temperature'
  def get_temperature room_name
    Inels::Controller.new(CONFIG['ips']).get_states(CONFIG['room names'].key(room_name)).each do |hcl_id, state|
      puts "#{hcl_id}: #{state['temperature']}[#{state['requested temperature']}]"
    end
  end

  desc 'get-all-temperature', 'Gets all room temperature'
  def get_all_temperature
    Inels::Controller.new(CONFIG['ips']).get_all_states.each do |id, states|
      puts "#{CONFIG['room names'][id]}: #{states.values.map{|state|"#{state['temperature']}[#{state['requested temperature']}]"}.join(', ')}"
    end
  end
end

InelsCLI.start