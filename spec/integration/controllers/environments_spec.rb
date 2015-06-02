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

  before(:each) do
    Manifest.collection.remove
    Environment.collection.remove
  end

  describe '/' do

    describe 'post' do

      it 'simple' do
        post '/', {:name => 'uat-team-a'}

        environment = Environment.first({:name => 'uat-team-a'})

        expect(last_response.ok?).to be true
        expect(environment.name).to eq 'uat-team-a'
      end

      it 'with manifests' do

        Manifest.create({:name => 'pr.123'})
        Manifest.create({:name => 'pr.234'})
        Manifest.create({:name => 'pr.345'})

        post '/', {
          :name => 'uat-team-a',
          :manifests => ['pr.123', 'pr.234', 'pr.345']
        }

        expect(last_response.ok?).to be true

        environment = Environment.first({:name => 'uat-team-a'})

        expect(environment.manifests.size).to eq 3
        expect(environment.manifests[0].name).to eq 'pr.123'
        expect(environment.manifests[1].name).to eq 'pr.234'
        expect(environment.manifests[2].name).to eq 'pr.345'
      end

    end

    it 'get' do

      post '/', {:name => 'uat-team-a'}
      get '/'

      expect(last_response.ok?).to eq true
      array = JSON.parse(last_response.body)
      result = array.first

      expect(result['name']).to eq 'uat-team-a'
    end

  end

  describe '/:name' do

    it 'get' do
      post '/', {:name => 'uat-team-a'}

      get '/uat-team-a'

      expect(last_response.ok?).to be true

      result = JSON.parse(last_response.body)

      expect(result['name']).to eq 'uat-team-a'
    end

    describe 'put' do

      before(:each) do
        Manifest.create({:name => 'pr.123'})
        Manifest.create({:name => 'pr.234'})
        Manifest.create({:name => 'pr.345'})
        Manifest.create({:name => 'pr.456'})
        Manifest.create({:name => 'pr.567'})

        post '/', {
          :name => 'uat-team-a',
          :manifests => ['pr.123', 'pr.234', 'pr.345']
        }

      end

      it 'with manifests' do

        put 'uat-team-a', {
          :manifests => ['pr.345', 'pr.567']
        }

        expect(last_response.ok?).to be true

        environment = Environment.first({:name => 'uat-team-a'})

        expect(environment.manifests.size).to eq 2
        expect(environment.manifests[0].name).to eq 'pr.345'
        expect(environment.manifests[1].name).to eq 'pr.567'

      end

    end

    it 'delete' do
      post '/', {:name => 'uat-team-a'}

      delete '/uat-team-a'

      expect(last_response.ok?).to be true

      expect(Manifest.collection.size).to eq 0
    end

  end

end
