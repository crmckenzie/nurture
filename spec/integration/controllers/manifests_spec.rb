require_relative '../../spec_helper'

describe Manifests do
  include Rack::Test::Methods

  before(:all) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

  subject { Manifests }

  # required by rack/test
  def app
    subject
  end

  describe '/' do

    before(:each) do
      Manifest.collection.remove
    end

    describe 'post' do

      it 'simple - manifest only' do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob'
        }

        release = Manifest.first

        expect(last_response.ok?).to be true
        expect(release.name).to eq 'pr.521'
        expect(release.description).to eq 'fredbob'
      end

      it 'complex - with application versions' do

          post '/', {
            :name => 'pr.521',
            :description => 'fredbob',
            :applications => {
              :notepad => '1.0',
              :dobby => '0.3.0.126'
            }
          }

          expect(last_response.ok?).to eq true

          result = Manifest.first({:name => 'pr.521'})

          expect(result).to_not be nil
          expect(result.application_ids.size).to eq 2
          expect(result.applications.size).to eq 2

          expect(result.applications[0].name).to eq 'notepad'
          expect(result.applications[0].version).to eq '1.0'

          expect(result.applications[1].name).to eq 'dobby'
          expect(result.applications[1].version).to eq '0.3.0.126'

      end

    end

    describe 'put' do

      before(:each) do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob'
        }
      end

      it 'simple - manifest only' do

        put '/', {
          :name => 'pr.521',
          :description => 'this is a test'
        }

        release = Manifest.first

        expect(last_response.ok?).to be true
        expect(release.name).to eq 'pr.521'
        expect(release.description).to eq 'this is a test'
      end

      it 'complex - with application versions' do

          put '/', {
            :name => 'pr.521',
            :description => 'fredbob',
            :applications => {
              :notepad => '1.0',
              :dobby => '0.3.0.126'
            }
          }

          expect(last_response.ok?).to eq true

          result = Manifest.first({:name => 'pr.521'})

          expect(result).to_not be nil
          expect(result.application_ids.size).to eq 2
          expect(result.applications.size).to eq 2

          expect(result.applications[0].name).to eq 'notepad'
          expect(result.applications[0].version).to eq '1.0'

          expect(result.applications[1].name).to eq 'dobby'
          expect(result.applications[1].version).to eq '0.3.0.126'

      end

    end

    it 'get' do
      post_data = {
        :name => 'pr.521',
        :description => 'fredbob'
      }

      post '/', post_data
      expect(last_response.ok?).to be true

      get '/'

      expect(last_response.ok?).to be true

      array = JSON.parse(last_response.body)
      result = array.first

      expect(result['name']).to eq post_data[:name]
      expect(result['description']).to eq post_data[:description]
      expect(result['created_at']).to_not be nil
      expect(result['updated_at']).to_not be nil
      expect(result['id']).to_not be nil

      expect(result['applications']).to_not be nil
      expect(result['applications']).to be_kind_of Array
    end

    it 'delete' do
      post '/', {
        :name => 'pr.521',
        :description => 'fredbob'
      }

      delete '/', { :name => 'pr.521' }

      expect(Manifest.collection.size).to eq 0

    end

    describe '/:name' do |variable|
      before(:each) do
        body = {
          :name => 'pr.346',
          :description => 'test release'
        }

        post '/', body
      end

      it 'get' do

        get '/pr.346'

        expect(last_response.ok?).to eq true

      end

    end

  end

end
