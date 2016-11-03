require 'mongo_record'

class Question
  include MongoRecord

  field :topic, String
  field :author, String
  field :content, String

  def before_save
    type_checking
  end

  def after_save
    clean_dirty
  end
end