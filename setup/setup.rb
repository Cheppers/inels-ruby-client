#!/usr/bin/env ruby

require 'yaml'
require_relative '../lib/inels'

def process_template template
  ERB.new(File.read(File.join(File.dirname(__FILE__), 'templates', template))).result(binding)
end

def post_template endpoint, path, template
  old_keys = endpoint.api_get(path).keys
  endpoint.api_post(path, process_template(template))
  new_keys = endpoint.api_get(path).keys
  (new_keys-old_keys).first
end

def create_valve endpoint, address
  @address = address.hex
  @type = 'thermometer'
  @product_type = 'RFATV-1'
  post_template endpoint, 'devices', 'device.erb'
end

def create_thermometer endpoint, address
  @address = address.hex
  @type = 'thermometer'
  @product_type = 'RFTI-10B'
  post_template endpoint, 'devices', 'device.erb'
end

def create_schedule endpoint
  post_template endpoint, 'temperature/schedules', 'schedule.erb'
end

def create_heating_area endpoint, schedule, temperature_sensor, heating_devices
  @schedule = schedule
  @temperature_sensor = temperature_sensor
  @heating_devices = heating_devices
  post_template endpoint, 'devices', 'heat_cool_area.erb'  
end

def create_boiler endpoint, address
  @address = address.hex
  @type = 'heating'
  @product_type = 'RFSA-61B'
  post_template endpoint, 'devices', 'device.erb' 
end

def create_source endpoint, boiler, areas
  @boiler = boiler
  @areas = areas
  post_template endpoint, 'temperature/sources'
end

endpoint = Inels::Client.new('192.168.1.32')
p create_thermometer(endpoint, '001A53')
# output = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config.yml')))
# id = 0
# output['clients'].each do |client|
#   endpoint = Inels::Client.new(client['ip'])
#   client['rooms'].each do |room|
#     room['heating areas'].each do |heating_area|
#       heating_area['valves'].each do |valve|
#         puts "Creating valve: #{valve['address']}"
#         valve['id'] = id
#       end
#       if heating_area['valves'].map{|v| v['address']}.include? heating_area['thermometer']['address']
#         puts "Thermometer already exists: #{heating_area['thermometer']['address']}"
#       else
#         puts "Creating thermometer: #{heating_area['thermometer']['address']}"
#       end
#       heating_area['schedule'] = {}
#       puts "Creating schedule"
#       heating_area['schedule']['id'] = id
#       puts "Creating heating area"
#     end
#     puts "Creating room: #{room['name']}"
#   end
#   puts "Creating boiler"
#   puts "Creating source"
# end
