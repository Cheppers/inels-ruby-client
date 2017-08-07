require 'rest-client'

IPS=['192.168.1.30', '192.168.1.31', '192.168.1.32']

def api_get path
  response = RestClient.get "http://#{@ip}/api/#{path}"
  JSON.parse(response.body)
end

# IPS.each do |ip|
#   @ip = ip
#   rooms = api_get('rooms')
#   rooms.each do |id, value|
#     room = api_get("rooms/#{id}")
#     puts room['room info']['label']
#     room['devices'].keys.each do |id|
#       device = api_get("devices/#{id}")
#       # puts "  #{device['device info']['product type']}(#{device['device info']['address']})"
#     end
#     # puts"#{room['room info']['label']}: #{temperature.join(', ')}"
#   end
# end
roomnames = JSON.parse(File.read('roomnames.json'))
IPS.each do |ip|
  @ip = ip
  rooms = api_get('rooms')
  rooms.each do |id, value| 
    room = api_get("rooms/#{id}")
    label = room['room info']['label']
    puts "#{label}(#{roomnames[label]})"
    room['devices'].keys.each do |id|
      device = api_get("devices/#{id}")
      if device['device info']['product type'] == 'RFATV-1'
        print '  '
        puts device['device info']['address'].to_s(16).rjust(6, "0")
      end
    end
    # puts"#{room['room info']['label']}: #{temperature.join(', ')}"
  end
end