#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require_relative '../inels'

module Inels
  # Helper methods for the controller and CLI.
  module Helpers
    def root
      File.join(File.dirname(__FILE__), '..', '..')
    end

    def load_config
      config_path = File.join(root, 'inels.yml')
      raise 'Config file not found' unless File.file?(config_path)

      YAML.safe_load(File.read(config_path))
    end

    def process_template(template)
      ERB.new(File.read(File.join(root, 'setup', 'templates', template)))\
         .result(binding)
    end

    def post_template(endpoint, path, template)
      old_keys = endpoint.api_get(path).keys
      endpoint.api_post(path, process_template(template))
      new_keys = endpoint.api_get(path).keys
      (new_keys - old_keys).first
    end

    def create_valve(endpoint, address)
      @address = address.hex
      @type = 'thermometer'
      @product_type = 'RFATV-1'
      post_template endpoint, 'devices', 'device.erb'
    end

    def create_thermometer(endpoint, address)
      @address = address.hex
      @type = 'thermometer'
      @product_type = 'RFTI-10B'
      post_template endpoint, 'devices', 'device.erb'
    end

    def create_schedule(endpoint)
      post_template endpoint, 'temperature/schedules', 'schedule.erb'
    end

    def create_heating_area(endpoint, schedule, sensor, devices)
      @schedule = schedule
      @temperature_sensor = sensor
      @heating_devices = devices
      post_template endpoint, 'devices', 'heat_cool_area.erb'
    end

    def create_boiler(endpoint, address)
      @address = address.hex
      @type = 'heating'
      @product_type = 'RFSA-61B'
      post_template endpoint, 'devices', 'device.erb'
    end

    def create_source(endpoint, boiler, areas)
      @boiler = boiler
      @areas = areas
      post_template endpoint, 'temperature/sources'
    end
  end
end
