require 'question'

class QuestionFactory
  def self.create(author = '', content = '')
    q = Question.new
    q.author  = author
    q.content = content
    q
  end

  def self.insert(author = '', content = '')
    q = self.create(author, content)
    q.save
    q
  end
end
