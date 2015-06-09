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

    before(:each) do
      post '/', {
        :manifests => ['pr.123', 'pr.234']
      }
    end

    describe 'post' do

      let(:release) {Release.first() }

      it 'is successful' do
        expect(last_response.ok?).to be true
      end

      it 'creates a release' do
        body = JSON.parse(last_response.body)

        expect(body['id']).to eq release.id.to_s
        names = release.manifests.map{|row| row.name}
        expect(names).to eq ['pr.123', 'pr.234']
      end

      it 'locks the associated manifests for editing' do
        release.manifests.each do |m|
          expect(m.status.to_sym).to eq :released
        end
      end

      it 'manifests are required.' do
        post '/', {
        }

        expect(last_response.ok?).to be false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['manifests'][0]).to eq 'at least one manifest is required.'

      end

      it 'cannot release manifest that has already been released' do
        post '/', {
          :manifests => ['pr.123']
        }

        expect(last_response.ok?).to be false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['manifests'][0]).to eq "'pr.123' has already been released."

      end

    end

    it 'get' do

      id = JSON.parse(last_response.body)['id']

      get "/#{id}"

      expect(last_response.ok?).to eq true

      record = JSON.parse(last_response.body)

      expect(record['manifests']).to eq ['pr.123', 'pr.234']
    end

  end

end
