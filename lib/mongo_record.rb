
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
        instance_variable_get(name.get_symbol)
      end

      define_method(name.set_symbol) do |value|
        if value.is_a? type
          instance_variable_set(name.get_symbol, value)
        else
          raise ArgumentError.new('Invalid Type')
        end
      end
    end

    def fields
      @fields.map { |f| f.name }
    end

    def ifields
      @fields
    end

    def collection(name)
      @collection_name = name.to_s.downcase
    end

    def collection_name
      @collection_name.nil? ? self.to_s.downcase << 's' : @collection_name
    end

    def mongo_collection
      MongoDB.client[collection_name]
    end

  end

  module InstanceMethods

    def asHash
      hash = {}
      self.class.ifields.each { |f| hash[f.name] = instance_variable_get f.name.get_symbol }
      hash
    end

    def save
      result = self.class.mongo_collection.insert_one(self.asHash)
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

# FIXME evaluar si mover a otro lado
class Symbol
  def get_symbol
    "@#{self}".to_sym
  end

  def set_symbol
    "#{self}="
  end
end
