# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'digest/sha1'

module Inels
  # Class handling an inels client.
  class Client
    AUTH_COOKIE = 'AuthAPI'

    def initialize(ip, username, password)
      @ip = ip
      @username = username
      @password = password
      login
    end

    attr_reader :ip, :devices

    def room(id)
      api_get("rooms/#{id}")
    end

    def rooms
      api_get('rooms')
    end

    def device(id)
      api_get("devices/#{id}")
    end

    def api_get(path)
      response = retry_login do
        RestClient.get(
          "#{base_url}/api/#{path}",
          cookies: { AUTH_COOKIE => @auth_token }
        )
      end
      JSON.parse(response.body)
    end

    def api_post(path, payload)
      response = retry_login do
        RestClient.post(
          "#{base_url}/api/#{path}",
          payload,
          content_type: :json,
          accept: :json,
          cookies: { AUTH_COOKIE => @auth_token }
        )
      end
      response.body
    end

    def api_delete(path)
      response = retry_login do
        RestClient.delete(
          "#{base_url}/api/#{path}",
          cookies: { AUTH_COOKIE => @auth_token }
        )
      end
      response.body
    end

    def api_put(path, payload)
      response = retry_login do
        RestClient.put(
          "#{base_url}/api/#{path}",
          payload,
          content_type: :json,
          accept: :json,
          cookies: { AUTH_COOKIE => @auth_token }
        )
      end
      response.body
    end

    def device?(id)
      refresh_devices unless @devices
      @devices.key?(id)
    end

    private

    def retry_login
      yield
    rescue RestClient::Unauthorized
      puts "Call failed with 401, retrying login to #{@ip}..."
      login
      yield
    end

    def login
      payload = { name: @username, key: Digest::SHA1.hexdigest(@password) }
      response = RestClient.post "#{base_url}/login", payload
      @auth_token = response.cookies[AUTH_COOKIE]
      refresh_devices
    end

    def refresh_devices
      response = RestClient.get(
        "#{base_url}/api/devices",
        cookies: { AUTH_COOKIE => @auth_token }
      )
      @devices = JSON.parse(response.body)
    end

    def base_url
      @base_url ||= "http://#{@ip}"
    end
  end
end
