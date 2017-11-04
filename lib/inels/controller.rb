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

    def set_temperature room_id, temperature, client = nil
      client ||= multi_client.client_for_id('rooms', room_id)

      get_heat_cool_areas(room_id, client).each do |hca| 
        schedule_id = hca['schedule']
        client.api_post('temperature/schedules', schedule.result(binding))
      end
    end

    def set_all_temperature temperature
      room_states = multi_client.clients.map do |client|
        rooms = client.api_get('rooms')
        rooms.keys.each do |room_id| 
          set_temperature room_id, temperature, client
        end
      end
    end

    def set_power room_id, power, client = nil
      client ||= multi_client.client_for_id('rooms', room_id)
      
      get_heat_cool_areas(room_id, client).each do |hca| 
        client.api_put("devices/#{hca['id']}", {power: power}.to_json)
      end
    end

    def get_states room_id, client = nil
      client ||= multi_client.client_for_id('rooms', room_id)

      get_heat_cool_areas(room_id, client).map do |hca|
        [hca['id'], client.api_get("devices/#{hca['id']}/state")]
      end.to_h
    end

    def get_all_states
      room_states = multi_client.clients.map do |client|
        rooms = client.api_get('rooms')
        rooms.keys.map do |room_id| 
          [room_id, get_states(room_id, client)]
        end
      end.flatten(1).to_h
    end

    def get_info room_id, client = nil
      client ||= multi_client.client_for_id('rooms', room_id)
      client.api_get("rooms/#{room_id}")
    end

    def get_all_info
      room_states = multi_client.clients.map do |client|
        rooms = client.api_get('rooms')
        rooms.keys.map do |room_id| 
          get_info(room_id, client)
        end
      end.flatten(1)
    end

    def get_heat_cool_areas room_id, client = nil
      client ||= multi_client.client_for_id('rooms', room_id)

      room = client.api_get("rooms/#{room_id}")

      devices = room['devices'].keys.map do |device_id|
        client.api_get("devices/#{device_id}")
      end

      devices.select do |device|
        device['device info']['product type'] == 'HeatCoolArea'
      end
    end
  end
end