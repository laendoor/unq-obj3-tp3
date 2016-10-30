require 'spec_helper'

describe Question do

  before :all do
    Mongo::Logger.logger = ::Logger.new('mongo.log')
  end

  describe 'Automatic behavior' do

    it 'has automatics accessors' do
      q = Question.new
      q.author  = 'Eduardo'
      q.content = '¿Cuál es el radio de la tierra?'

      expect(q.author).to eq 'Eduardo'
      expect(q.content).to eq '¿Cuál es el radio de la tierra?'
    end

    it 'reflects fields' do
      expect(Question.fields).to eq ([:author, :content])
    end

    it 'reflects collection name' do
      expect(Question.collection_name).to eq 'questions'
    end

    it 'can return hash of fields' do
      q = Question.new
      q.author  = 'Eduardo'
      q.content = 'ABC?'

      expect(q.asHash).to eq ({:author => 'Eduardo', :content => 'ABC?'})
    end

  end

  describe 'Custom behavior' do

    before :all do
      class Question
        collection :questionsss
      end
    end

    it 'reflects custom collection name' do
      expect(Question.collection_name).to eq 'questionsss'
    end
  end

  describe 'Persistence' do

    before :all do
      class Question
        collection :questions
      end

      @collection = Question.mongo_collection
    end

    it 'can save fields as mongo documents' do
      q = Question.new
      q.author  = 'Eduardo'
      q.content = 'ABC?'
      q.save

      found = @collection.find({ author: 'Eduardo' }).first

      expect(found[:author]).to eq(q.asHash[:author])
      expect(found[:content]).to eq(q.asHash[:content])
    end
  end
end
