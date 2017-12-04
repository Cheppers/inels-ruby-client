#!/usr/bin/env ruby

require 'thor'
require_relative '../lib/inels'

IPS = %w(192.168.1.30 192.168.1.31 192.168.1.32)

class InelsCLI < Thor

  desc 'list', 'List all devices'
  def list 
    Inels::Controller.new(IPS).list
  end

  desc 'get-temperature', 'Gets device\'s temperature'
  def get_temperature id
    Inels::Controller.new(IPS).get_device(id)
  end

  desc 'set-temperature', 'Sets device\'s temperature'
  def set_temperature id, temperature
    Inels::Controller.new(IPS).set_temperature(id, Integer(temperature))
  end

end

InelsCLI.start