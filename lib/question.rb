require 'mongo_record'

class Question
  include MongoRecord

  field :topic, String
  field :author, String
  field :content, String
end