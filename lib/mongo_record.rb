require 'symbol'

module MongoRecord

  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods

    def method_missing(method, *arguments, &block)
      if is_find_by?(method)
        find_by(extract_find_by(method), arguments)
      elsif is_find_one_by?(method)
        find_one_by(extract_find_one_by(method), arguments)
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

    def field(name, type, constraints = {})
      @fields = [] if @fields.nil?
      @fields << Field.new(name, type, constraints[:required])

      define_method(name) do
        instance_variable_get name.symbol_get
      end

      define_method(name.symbol_set) do |value|
        instance_variable_set(:@dirty, true)
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

    def is_find_one_by?(method)
      method.to_s.start_with? 'find_one_by_'
    end

    def extract_find(type, method)
      ini = type.size
      fin = method.size
      method[ini..fin]
      end

    def extract_find_by(method)
      extract_find('find_by_', method)
    end

    def extract_find_one_by(method)
      extract_find('find_one_by_', method)
    end

    def find_by(method, *args)
      hash   = {}
      values = args.first
      fields = method.split '_and_'
      fields.each { |field| hash[field.to_sym] = values.shift }
      find(hash)
    end

    def find_one_by(method, *args)
      find_by(method, *args).first
    end

    def map_results(results)
      results.map { |item| map_item item }
    end

    def map_item(item)
      i = self.new
      item.each do |key, value|
        i.instance_variable_set(key.to_sym.symbol_get, value)
      end
      i.instance_eval(&@on_populate)
      i
    end

    def on_populate(&block)
      @on_populate = block
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

    def before_save
      # Should Be Implemented by each class
    end

    def after_save
      # Should Be Implemented by each class
    end

    def save
      required_checking
      before_save

      self._id = BSON::ObjectId.new.to_s if self._id.nil?

      if collection.find(:_id => self._id).first.nil?
        collection.insert_one as_hash
      else
        collection.update_one({ :_id => self._id }, self.as_hash)
      end

      after_save
    end

    def remove
      collection.delete_one({:_id => self._id})
    end

    def required_checking
      self.class.get_fields.select {|f| f.required }.each do |field|
        get_field = instance_variable_get(field.name.symbol_get)
        if get_field.nil? || get_field.empty?
          raise MongoRequiredFieldError.new field.name.to_s
        end
      end
    end

    def type_checking
      self.class.get_fields.each do |field|
        unless instance_variable_get(field.name.symbol_get).is_a? field.type
          name   = field.name.to_s
          expect = field.type.to_s
          given  = instance_variable_get(field.name.symbol_get).class.to_s
          raise MongoTypeCheckingError.new name, expect, given
        end
      end
    end

    def clean_dirty
      instance_variable_set(:@dirty, false)
    end

    def dirty
      instance_variable_get(:@dirty)
    end

  end

  class Field
    attr_accessor :name, :type, :required

    def initialize(name, type, required)
      self.name = name
      self.type = type
      self.required = required
    end
  end

end

