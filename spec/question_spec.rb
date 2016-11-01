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

    it 'can return a hash of fields' do
      q = Question.new
      q.author  = 'Eduardo'
      q.content = 'ABC?'

      expect(q.as_hash).to eq ({:author => 'Eduardo', :content => 'ABC?',:_id =>nil})
    end

  end

  describe 'Custom behavior' do

    before :all do
      class Question
        collection :questionsss
      end
    end

    after :all do
      Question.reset_collection_name
    end

    it 'reflects custom collection name' do
      expect(Question.collection_name).to eq 'questionsss'
    end
  end

  describe 'Type checking' do

    it 'raise Argument Error when type mismatch' do
      q = Question.new

      expect { q.author  = 2 }.to raise_error(ArgumentError, 'Invalid Type')
      expect { q.content = true }.to raise_error(ArgumentError, 'Invalid Type')
    end

  end

  describe 'Persistence' do

    before :all do
      Question.collection.drop
    end

    after :each do
      Question.collection.drop
    end

    it 'can get mongo collection by class or instance' do
      q = Question.new

      expect(q.collection).to be_a Mongo::Collection
      expect(Question.collection).to be_a Mongo::Collection
    end

    it 'can save fields as mongo documents' do
      q = Question.new
      q.author  = 'Eduardo'
      q.content = 'ABC?'
      q.save

      found = q.collection.find({ author: 'Eduardo' }).first

      expect(found[:author]).to eq 'Eduardo'
      expect(found[:content]).to eq 'ABC?'
    end

    it 'I test the count method returns the number of items in the collection' do


      old = Question.count()
      Question.new().save()
      expect(Question.count()).to eq (old + 1)


    end

    it 'prueba de _id' do

      q = Question.new()
      q.save()
      expect(q._id).not_to be nil


    end

    it 'prueba de remove' do



      q = Question.new()
      q.save()
      old = Question.count()


      q.remove()


      expect(Question.count()).to eq (old - 1)


    end

  end
end
