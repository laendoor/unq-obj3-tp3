require 'symbol'

module MongoRecord

  def self.included(base)
    base.include(InstanceMethods)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def field(name, type)
      @fields = [] if @fields.nil?
      @fields << Field.new(name, type)

      define_method(name) do
        instance_variable_get name.symbol_get
      end

      define_method(name.symbol_set) do |value|
        raise ArgumentError.new 'Invalid Type' unless value.is_a? type
        instance_variable_set(name.symbol_get, value)
      end
    end

    def fields
      @fields.map { |f| f.name }
    end

    def get_fields
      @fields
    end

    def collection(name)
      @collection_name = name.to_s.downcase
    end

    def reset_collection_name
      @collection_name = nil
    end

    def collection_name
      @collection_name.nil? ? self.to_s.downcase << 's' : @collection_name
    end

    def mongo_collection
      MongoDB.client[collection_name]
    end

  end

  module InstanceMethods

    def as_hash
      hash = {}
      self.class.get_fields.each { |f| hash[f.name] = instance_variable_get f.name.symbol_get }
      hash
    end

    def save
      result = self.class.mongo_collection.insert_one self.as_hash
      result.n
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

