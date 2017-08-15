require_relative 'client'

class MultiClient
  def initialize ips
    @clients = ips.map{ |ip| Client.new(ip)}
  end

  attr_reader :clients

  def client_for_id path, id
    clients.each do |client|
      hash = client.api_get(path)
      return client if hash.keys.include?(id)
    end
    nil
  end

end