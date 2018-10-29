# frozen_string_literal: true

require 'concurrent'
require 'erb'
require 'parallel'
require_relative 'multi_client'

module Inels
  # Class for inels controllers.
  class Controller
    def initialize(clients)
      @multi_client = MultiClient.new(clients)
      cache_init
    end

    attr_reader :multi_client

    def devices(purge_cache: false)
      cache_init if purge_cache
      clients = multi_client.clients

      @devices ||= Parallel.map(clients, in_threads: clients.count) do |client|
        find_all_devices(client.rooms.keys, client)
      end.flatten
    end

    def device(id, client: nil, verbose: false)
      return @device_state_cache[id] if @device_state_cache.key? id

      client ||= multi_client.client_for_device(id)
      device_state = client.api_get("devices/#{id}/state")

      device_state['valves'] = verbose_device_information(id, client) if verbose

      @device_state_cache[id] = device_state
      device_state
    end

    def set_temperature(id, temperature, client: nil)
      client ||= multi_client.client_for_device(id)
      schedule_id = client.api_get("devices/#{id}")['schedule']
      client.api_post('temperature/schedules', schedule_file.result(binding))

      refresh_device_state(id)
    end

    def set_correction(id, correction, client: nil)
      client ||= multi_client.client_for_device(id)
      client.api_put("devices/#{id}", { correction: correction }.to_json)
      refresh_device_state(id)
    end

    def set_power(id, power, client: nil)
      client ||= multi_client.client_for_device(id)
      client.api_put("devices/#{id}", { power: power }.to_json)
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

    def schedule_template_path
      File.join(File.dirname(__FILE__), 'templates/schedule.erb')
    end

    def schedule_file
      ERB.new(File.read(template_path))
    end

    def describe_device(id, room, client)
      device = client.device(id)
      {
        id: device['id'],
        name: device['device info']['label'],
        product_type: device['device info']['product type'],
        room_name: room['room info']['label'],
        ip: client.ip
      }
    end

    def find_all_devices(rooms, client)
      Parallel.map(rooms, in_threads: rooms.count) do |room_id|
        room = client.room(room_id)
        devices = room['devices'].keys

        devices_in_room(room, devices, client)
      end
    end

    def devices_in_room(room, devices, client)
      devices.map do |device_id|
        describe_device(device_id, room, client)
      end.compact
    end

    def verbose_device_information(id, client)
      device = client.device(id)
      device['heating devices']&.map do |valve|
        client.api_get("devices/#{valve['id']}/state")
      end
    end
  end
end
