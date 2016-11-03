require 'mongo_record'

class Person
  include MongoRecord

  field :name, String

  def initialize(name = '')
    self.name = name
  end

  def to_s
    name.to_s
  end

  def to_str
    self.to_s
  end

end