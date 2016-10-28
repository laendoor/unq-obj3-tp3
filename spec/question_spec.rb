require 'question'
require 'spec_helper'

describe Question do

  it 'rspec works' do
    expect(true).to be true
  end

  it 'has automatics accessors' do
    q = Question.new
    q.author  = 'Eduardo'
    q.content = 'Cual es el radio de la tierra'

    expect(q.author).to eq 'Eduardo'
    expect(q.content).to eq 'Cual es el radio de la tierra'
  end

  it 'reflects fields' do
    expect(Question.fields).to eq ([:author, :content])
    end

  it 'reflects collection name' do
    expect(Question.collection_name).to eq 'questions'
    end

  it 'reflects custom collection name' do
    class Question
      collection :questionsss
    end
    expect(Question.collection_name).to eq 'questionsss'
  end
end
