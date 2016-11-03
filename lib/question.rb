require 'mongo_record'

class Question
  include MongoRecord

  field :topic, String
  field :author, String
  field :content, String

  def before_save
    unless author.is_a? String 
      raise MongoMapperError.new 'Author should be String'
    end
  end
end