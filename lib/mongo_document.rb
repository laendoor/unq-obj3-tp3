
module MongoDocument
    @@client = nil

    def self.client
        if @@client == nil
            @@client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'preguntas')
        end
        @@client
    end
end
