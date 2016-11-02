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


      findByName = "findBy" + name.to_s
      define_singleton_method(findByName) do |value|
        @collection = MongoDB.client[collection_name]
        criterio={name=>value}
        return collection.find (criterio)
      end
    end


    def count
      collection.count
    end

    def find(hash = {})
      map_results collection.find(hash)
    end

    def map_results(results)
      results.map { |item| map_item item }
    end

    def map_item(item)
      i = self.new
      item.each do |key, value|
        i.instance_variable_set(key.to_sym.symbol_get, value)
      end
      i
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
      self._id = BSON::ObjectId.new.to_s if self._id.nil?

      if collection.find(:_id => self._id).first.nil? # FIXME
        collection.insert_one as_hash
      else
        collection.update_one({ :_id => self._id }, self.as_hash)
      end

    end

    def remove
      collection.delete_one({:_id => self._id})
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

