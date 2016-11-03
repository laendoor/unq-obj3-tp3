require 'spec_helper'
require 'factory/question_factory'

describe Question do

  before :all do
    Mongo::Logger.logger = ::Logger.new('mongo.log')
  end

  after :all do
    Question.collection.drop
  end

  describe 'Behavior' do
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
        q = QuestionFactory.create(author = 'Eduardo', content = 'ABC?')

        expect(q.as_hash).to eq ({
          :_id => nil,
          :author => 'Eduardo',
          :content => 'ABC?'
        })
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

    it 'can get mongo collection by class' do
      expect(Question.collection).to be_a Mongo::Collection
    end

    it 'can get mongo collection by instance' do
      expect(Question.new.collection).to be_a Mongo::Collection
    end

    it 'can insert a new mongo document when save' do
      q = QuestionFactory.create(author = 'Eduardo', content = 'ABC?')
      q.save

      found = q.collection.find(:_id => q._id).first

      expect(found[:_id]).to eq q._id
      expect(found[:author]).to eq 'Eduardo'
      expect(found[:content]).to eq 'ABC?'
    end

    it 'can update existing mongo document when save' do
      q = QuestionFactory.create(author = 'Eduardo')
      q.save

      found = q.collection.find(:_id => q._id).first
      expect(found[:author]).to eq 'Eduardo'

      q.author = 'Esteban'
      q.save

      found = q.collection.find(:_id => q._id).first
      expect(found[:author]).to eq 'Esteban'
    end

    it 'can count the number of documents in the collection' do
      count = Question.count
      QuestionFactory.insert

      expect(Question.count).to eq (count + 1)
    end

    it 'can set _id field before save' do
      q = QuestionFactory.create
      expect(q._id).to be nil

      q.save
      expect(q._id).not_to be nil
    end

    it 'can remove a mongo document' do
      q = QuestionFactory.insert
      count = Question.count
      expect(q.collection.find(:_id => q._id).first).not_to be nil

      q.remove
      expect(Question.count).to eq (count - 1)
      expect(q.collection.find(:_id => q._id).first).to be nil
    end

  end

  describe 'Finders' do

    before :all do
      Question.collection.drop

      QuestionFactory.insert(author = 'Javier',  content = 'Bla1')
      QuestionFactory.insert(author = 'Javier',  content = 'Bla2')
      QuestionFactory.insert(author = 'Ariel',   content = 'Bla3')
      QuestionFactory.insert(author = 'Emanuel', content = 'Bla4')
      QuestionFactory.insert(author = 'Facundo', content = 'Bla5')
      QuestionFactory.insert(author = 'Leandro', content = 'Bla6')
    end

    describe 'Basic Find' do

      it 'can find all documents' do
        results = Question.find
        result_authors = results.map { |x| x.author }

        expect(results.count).to be 6
        expect(result_authors).to include 'Javier'
        expect(result_authors).to include 'Ariel'
        expect(result_authors).to include 'Emanuel'
        expect(result_authors).to include 'Facundo'
        expect(result_authors).to include 'Leandro'
      end

      it 'can find filtering by _id in hash' do
        q = QuestionFactory.insert
        results = Question.find({:_id => q._id})

        expect(results.count).to be 1
        expect(results.first._id).to eq q._id
      end

      it 'can find filtering by author in hash' do
        results = Question.find({:author => 'Javier'})
        result_authors = results.map { |x| x.author }

        expect(results.count).to be 2
        expect(result_authors).to include 'Javier'
        expect(result_authors).not_to include 'Ariel'
      end

    end

    describe 'Dynamic Find' do

      it 'can find by author' do
        results = Question.find_by_author('Ariel')

        expect(results.count).to eq 1
        expect(results.first.author).to eq 'Ariel'
      end

    end

  end

end
