require 'rest-client'
require 'json'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']

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

room_names = JSON.parse(File.read('roomnames.json'))

i = 0;
IPS.each do |ip|
  @ip = ip
  rooms = api_get('temperature/schedules')
  rooms.each do |id, value|
    api_delete "temperature/schedules/#{id}"
  end
end