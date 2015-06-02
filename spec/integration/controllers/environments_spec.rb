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

    it 'get' do

      post '/uat-team-a'
      get '/'

      expect(last_response.ok?).to eq true
      array = JSON.parse(last_response.body)
      result = array.first

      expect(result['name']).to eq 'uat-team-a'
    end

  end

  describe '/:name' do

    before(:each) do
      Environment.collection.remove
    end

    describe 'post' do

      it 'simple - manifest only' do
        post '/uat-team-a'

        environment = Environment.first

        expect(last_response.ok?).to be true
        expect(environment.name).to eq 'uat-team-a'
      end

    end

    it 'get' do
      post '/uat-team-a'

      get '/uat-team-a'

      expect(last_response.ok?).to be true

      result = JSON.parse(last_response.body)

      expect(result['name']).to eq 'uat-team-a'
    end

    describe 'put' do

      before(:each) do
        post '/uat-team-a'
      end

      it 'simple' do

        put '/uat-team-a'

        environment = Environment.first

        expect(last_response.ok?).to be true
        expect(environment.name).to eq 'uat-team-a'
      end

    end

    it 'delete' do
      post '/uat-team-a'

      delete '/uat-team-a'

      expect(last_response.ok?).to be true

      expect(Manifest.collection.size).to eq 0
    end

  end

end
