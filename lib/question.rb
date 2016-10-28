require 'mongo_db'

class Question
  include MongoDB

  field :author, String
  field :content, String
end