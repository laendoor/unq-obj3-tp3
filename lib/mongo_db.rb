
module MongoDB

  def self.included(base)
    base.include(InstanceMethods)
    base.extend(ClassMethods)
  end

  module ClassMethods
    @@client = nil

    def client
      if @@client.nil?
        @@client = Mongo::Client.new(
          ['127.0.0.1:27017'],
          :database => 'preguntas'
        )
      end
      @@client
    end

    def field(name, type)
      @fields = [] if @fields.nil?
      @fields << name

      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |value|
        if value.is_a? type
          instance_variable_set("@#{name}", value)
        else
          raise ArgumentError.new('Invalid Type')
        end
      end
    end

    def fields
      @fields
    end

    def collection(name)
      @collection_name = name.to_s.downcase
    end

    def collection_name
      @collection_name.nil? ? self.to_s.downcase << 's' : @collection_name
    end

  end

  module InstanceMethods

  end

end
