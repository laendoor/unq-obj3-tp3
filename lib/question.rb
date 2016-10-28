require 'mongo_db'

class Question
  include MongoDB
  extend MongoDB

  field :author, String
  field :content, String
end