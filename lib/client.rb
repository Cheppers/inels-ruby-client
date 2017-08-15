require 'rest-client'
require 'json'

module Inels
  class Client
    def initialize ip
      @ip = ip
    end

    def api_get path
      response = RestClient.get "http://#{@ip}/api/#{path}"
      JSON.parse(response.body)
    end

    def api_post path, payload
      response = RestClient.post "http://#{@ip}/api/#{path}", payload, {content_type: :json, accept: :json}
      response.body
    end

    def api_delete path
      response = RestClient.delete "http://#{@ip}/api/#{path}"
      response.body
    end
  end
end