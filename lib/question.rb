require 'mongo_record'

class Question
  include MongoRecord

  field :author, String
  field :content, String
end