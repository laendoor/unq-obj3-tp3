require 'person'
require 'mongo_record'

class Question
  include MongoRecord

  field :topic, String
  field :author, Person, :required => true
  field :content, String, :required => true
  field :bla, Integer, {:min => 1, :max => 10}

  def initialize
    @populate_called = false
  end

  on_populate {
    @populate_called = true
  }

  def before_save
    type_checking
  end

  def after_save
    clean_dirty
  end

  # esto es solo para testear
  def populate_called
    @populate_called
  end
end