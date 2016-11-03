
class MongoMapperError < StandardError
  def initialize(msg = 'Mapping Error')
    super
  end
  end

class MongoRequiredFieldError < MongoMapperError
  def initialize(field_name)
    msg = "The field <#{field_name}> is required."
    super msg
  end
  end

class MongoTypeCheckingError < MongoMapperError
  def initialize(field_name, type_expect, type_given)
    msg = "The field <#{field_name}> requires a <#{type_expect}> type, but got a <#{type_given}> instead."
    super msg
  end
end