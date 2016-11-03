require 'symbol'

module MongoRecord

  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods

    def method_missing(method, *arguments, &block)
      if is_find_by?(method)
        find_by(extract_find(method), arguments)
      else
        super
      end
    end

    def respond_to?(method, include_private = false)
      if is_find_by?(method)
        true
      else
        super
      end
    end

    def field(name, type)
      @fields = [] if @fields.nil?
      @fields << Field.new(name, type) #<< es como el método add

      define_method(name) do
        instance_variable_get name.symbol_get
      end

      define_method(name.symbol_set) do |value|
        raise ArgumentError.new 'Invalid Type' unless value.is_a? type
        instance_variable_set(name.symbol_get, value)
      end
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

    def count
      collection.count
    end

    def find(hash = {})
      map_results collection.find(hash)
    end

    def is_find_by?(method)
      method.to_s.start_with? 'find_by_'
    end

    def extract_find(method)
      ini = 'find_by_'.size
      fin = method.size
      method[ini..fin]
    end

    def find_by(method, *args)
      hash   = {}
      values = args.first
      fields = method.split '_and_'
      fields.each { |field| hash[field.to_sym] = values.shift }
      find(hash)
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

