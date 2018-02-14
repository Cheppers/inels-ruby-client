require 'erb'
require_relative 'multi_client'

module Inels
  class Controller
    def initialize ips
      @multi_client = MultiClient.new(ips)
      @schedule = ERB.new(File.read(File.join(File.dirname(__FILE__), 'templates/schedule.erb')))
    end

    attr_reader :multi_client
    attr_reader :schedule

    def list_devices
      room_states = multi_client.clients.map do |client|
        rooms = client.api_get('rooms')
        rooms.keys.map do |room_id| 
          room = client.api_get("rooms/#{room_id}")
          devices = room['devices'].keys.map do |device_id|
            device = client.api_get("devices/#{device_id}")
            case device['device info']['product type']
            when 'HeatCoolArea'
              device['room_name'] = room['room info']['label']
              device['ip'] = client.ip
              {
                id: device['id'],
                name: device['device info']['label'],
                product_type: device['device info']['product type'],
                room_name: room['room info']['label'],
                ip: client.ip
              }
            else
              nil
            end
          end.compact
        end
      end.flatten
    end

    def get_device id, client: nil, verbose: false
      client ||= multi_client.client_for_id('devices', id)
      device_state = client.api_get("devices/#{id}/state")
      if verbose
        device = client.api_get("devices/#{id}")

        device_state['valves'] = device['heating devices'].map do |valve|
          client.api_get("devices/#{valve['id']}/state")
        end
      end
      device_state
    end

    def set_temperature id, temperature, client: nil
      client ||= multi_client.client_for_id('devices', id)
      schedule_id = client.api_get("devices/#{id}")['schedule']
      client.api_post('temperature/schedules', schedule.result(binding))
    end

    def set_correction id, correction, client: nil
      client ||= multi_client.client_for_id('devices', id)
      client.api_put("devices/#{id}", {correction: correction}.to_json)
    end

    def set_power id, power, client: nil
      client ||= multi_client.client_for_id('devices', id)
      client.api_put("devices/#{id}", {power: power}.to_json)
    end
  end
end