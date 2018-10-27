require 'concurrent'
require 'erb'
require 'parallel'
require_relative 'multi_client'

module Inels
  class Controller
    def initialize(clients)
      @multi_client = MultiClient.new(clients)
      @schedule = ERB.new(File.read(File.join(File.dirname(__FILE__), 'templates/schedule.erb')))
      cache_init
    end

    attr_reader :multi_client
    attr_reader :schedule

    def list_devices(purge_cache: false)
      cache_init if purge_cache
      @device_cache ||= Parallel.map(multi_client.clients, in_threads: multi_client.clients.count) do |client|
        rooms = client.api_get('rooms')
        Parallel.map(rooms.keys, in_threads: rooms.keys.count) do |room_id|
          room = client.api_get("rooms/#{room_id}")
          room['devices'].keys.map do |device_id|
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
      return @device_state_cache[id] if @device_state_cache.has_key? id
      client ||= multi_client.client_for_device(id)
      device_state = client.api_get("devices/#{id}/state")
      if verbose
        device = client.api_get("devices/#{id}")
        device_state['valves'] = device['heating devices'].map do |valve|
          client.api_get("devices/#{valve['id']}/state")
        end
      end
      @device_state_cache[id] = device_state
      device_state
    end

    def set_temperature id, temperature, client: nil
      client ||= multi_client.client_for_device(id)
      schedule_id = client.api_get("devices/#{id}")['schedule']
      client.api_post('temperature/schedules', schedule.result(binding))
      refresh_device_state(id)
    end

    def set_correction id, correction, client: nil
      client ||= multi_client.client_for_device(id)
      client.api_put("devices/#{id}", {correction: correction}.to_json)
      refresh_device_state(id)
    end

    def set_power id, power, client: nil
      client ||= multi_client.client_for_device(id)
      client.api_put("devices/#{id}", {power: power}.to_json)
      refresh_device_state(id)
    end

    def cache_init
      @device_state_cache = Concurrent::Hash.new
      @device_cache = nil
    end

    private

    def refresh_device_state(id)
      @device_state_cache.delete(id)
      get_device(id)
    end
  end
end
