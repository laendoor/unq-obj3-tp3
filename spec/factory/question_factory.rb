require 'question'

class QuestionFactory
  def self.create(author = '', content = '', topic = '')
    q = Question.new
    q.topic   = topic
    q.author  = author
    q.content = content
    q
  end

  def self.insert(author = '', content = '', topic = '')
    q = self.create(author, content, topic)
    q.save
    q
  end
end