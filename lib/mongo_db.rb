require 'mongo'

class MongoDB

  @@client = nil

  def self.client
    if @@client.nil?
      @@client = Mongo::Client.new(
        ['127.0.0.1:27017'],
        :database => 'meta'
      )
    end
    @@client
  end

end
