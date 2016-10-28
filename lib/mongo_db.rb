
module MongoDB
  @@client = nil
  @@fields = []

  def self.client
    if @@client == nil
      @@client = Mongo::Client.new(
        ['127.0.0.1:27017'],
        :database => 'preguntas'
      )
    end
    @@client
  end

  def field(name, type)
    @@fields << name

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
    @@fields
  end

end
