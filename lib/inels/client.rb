require 'rest-client'
require 'json'
require 'digest/sha1'

module Inels
  class Client
    AUTH_COOKIE = 'AuthAPI'.freeze

    def initialize(ip, username, password)
      @ip = ip
      @username = username
      @password = password
      login
    end

    attr_reader :ip, :devices

    def api_get(path)
      response = retry_login do
        RestClient.get(
          "http://#{@ip}/api/#{path}",
          { cookies: { AUTH_COOKIE => @auth_token } }
        )
      end
      JSON.parse(response.body)
    end

    def api_post(path, payload)
      response = retry_login do
        RestClient.post(
          "http://#{@ip}/api/#{path}",
          payload,
          { content_type: :json, accept: :json, cookies: { AUTH_COOKIE => @auth_token } }
        )
      end
      response.body
    end

    def api_delete(path)
      response = retry_login do
        RestClient.delete(
          "http://#{@ip}/api/#{path}",
          { cookies: { AUTH_COOKIE => @auth_token } }
        )
      end
      response.body
    end

    def api_put(path, payload)
      response = retry_login do
        RestClient.put(
          "http://#{@ip}/api/#{path}",
          payload,
          { content_type: :json, accept: :json, cookies: { AUTH_COOKIE => @auth_token } }
        )
      end
      response.body
    end

    def has_device?(id)
      refresh_devices unless @devices
      @devices.has_key?(id)
    end

    private

    def retry_login(&block)
      begin
        yield
      rescue RestClient::Unauthorized => e
        puts "Call failed with 401, retrying login to #{@ip}..."
        login
        yield
      end
    end

    def login
      payload = { name: @username, key: Digest::SHA1.hexdigest(@password) }
      response = RestClient.post "http://#{@ip}/login", payload
      @auth_token = response.cookies[AUTH_COOKIE]
      refresh_devices
    end

    def refresh_devices
      response = RestClient.get(
        "http://#{@ip}/api/devices",
        { cookies: { AUTH_COOKIE => @auth_token } }
      )
      @devices = JSON.parse(response.body)
    end

  end
end
