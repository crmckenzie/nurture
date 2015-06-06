require_relative '../../spec_helper'

describe Releases do
  include Rack::Test::Methods

  before(:all) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

  before(:each) do
    Release.collection.remove
    Manifest.collection.remove

    Manifest.create({:name => 'pr.123'})
    Manifest.create({:name => 'pr.234'})
  end

  subject { Releases }

  # required by rack/test
  def app
    subject
  end

  describe '/' do

    it 'post' do

      post '/', {
        :manifests => ['pr.123', 'pr.234']
      }

      release = Release.first

      expect(last_response.ok?).to be true

      body = JSON.parse(last_response.body)

      expect(body['id']).to eq release.id.to_s
      names = release.manifests.map{|row| row.name}
      expect(names).to eq ['pr.123', 'pr.234']

    end

    it 'get' do

      post '/', {
        :manifests => ['pr.123', 'pr.234']
      }

      id = JSON.parse(last_response.body)['id']

      get "/#{id}"

      expect(last_response.ok?).to eq true

      record = JSON.parse(last_response.body)

      expect(record['manifests']).to eq ['pr.123', 'pr.234']
    end

  end

end
