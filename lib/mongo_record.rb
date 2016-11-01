require 'symbol'

module MongoRecord

  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods

    def field(name, type)
      @fields = [] if @fields.nil?
      @fields << Field.new(name, type) #<< es como el metodo add

      define_method(name) do
        instance_variable_get name.symbol_get
      end

      define_method(name.symbol_set) do |value|
        raise ArgumentError.new 'Invalid Type' unless value.is_a? type
        instance_variable_set(name.symbol_get, value)
      end
    end

    def count()
      @collection = MongoDB.client[collection_name]
      return collection.count()
    end


    def fields
      @fields.map { |field| field.name }
    end

    def get_fields
      @fields
    end

    def collection(name = nil)
      if name.nil?
        MongoDB.client[collection_name]
      else
        @collection_name = name.to_s.downcase
      end
    end

    def reset_collection_name
      @collection_name = nil
    end

    def collection_name
      @collection_name.nil? ? self.to_s.downcase << 's' : @collection_name
    end

  end

  module InstanceMethods

    attr_accessor :_id

    def collection
      self.class.collection
    end

    def as_hash
      hash = {}
      self.class.get_fields.each { |f| hash[f.name] = instance_variable_get f.name.symbol_get }
      hash[:_id] = _id
      hash
    end

    def save
      self.generateId
      result = collection.insert_one as_hash
      result.n
    end

    def remove
      collection.delete_one({"_id" => self._id})
    end

    def generateId
      if _id.nil?
        self._id= BSON::ObjectId.new
     end
    end
  end

  class Field
    attr_accessor :name, :type

    def initialize(name, type)
      self.name = name
      self.type = type

    end
  end

end

