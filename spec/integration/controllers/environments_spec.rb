require_relative '../../spec_helper'

describe Environments do
  include Rack::Test::Methods

  before(:all) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

  subject { Environments }

  # required by rack/test
  def app
    subject
  end

  describe '/' do

    before(:each) do
      Environment.collection.remove
    end

    describe 'post' do

      it 'simple - manifest only' do
        post '/', {
          :name => 'uat-team-a'
        }

        environment = Environment.first

        expect(last_response.ok?).to be true
        expect(environment.name).to eq 'uat-team-a'
      end

    end

    describe 'put' do

      before(:each) do
        post '/', {
          :name => 'uat-team-a'
        }
      end

      it 'simple - manifest only' do

        put '/', {
          :name => 'uat-team-a'
        }

        environment = Environment.first

        expect(last_response.ok?).to be true
        expect(environment.name).to eq 'uat-team-a'
      end

    end

    it 'get' do
      post_data = {
        :name => 'uat-team-a'
      }

      post '/', post_data
      expect(last_response.ok?).to be true

      get '/'

      expect(last_response.ok?).to be true

      array = JSON.parse(last_response.body)
      result = array.first

      expect(result['name']).to eq post_data[:name]
    end

    it 'delete' do
      post '/', {
        :name => 'uat-team-a'
      }

      delete '/', { :name => 'uat-team-a' }

      expect(Manifest.collection.size).to eq 0

    end

    describe '/:name' do
      before(:each) do
        body = {
          :name => 'uat-team-a'
        }

        post '/environments', body
      end

      it 'get' do

        get '/uat-team-a'

        expect(last_response.ok?).to eq true

      end

    end

  end

end
