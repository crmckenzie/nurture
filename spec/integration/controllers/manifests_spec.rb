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

  describe '/name' do

    before(:each) do
      Manifest.collection.remove
    end

    describe 'post' do

      it 'simple - manifest only' do
        post '/pr.521', {
          :description => 'fredbob'
        }

        release = Manifest.first

        expect(last_response.ok?).to be true
        expect(release.name).to eq 'pr.521'
        expect(release.description).to eq 'fredbob'
      end

      it 'complex - with application versions' do

          post '/pr.521', {
            :description => 'fredbob',
            :application_versions => {
              :notepad => '1.0',
              :dobby => '0.3.0.126'
            }
          }

          expect(last_response.ok?).to eq true

          result = Manifest.first({:name => 'pr.521'})

          expect(result).to_not be nil
          expect(result.application_versions.size).to eq 2

          expect(result.application_versions[0].application.name).to eq 'notepad'
          expect(result.application_versions[0].value).to eq '1.0'

          expect(result.application_versions[1].application.name).to eq 'dobby'
          expect(result.application_versions[1].value).to eq '0.3.0.126'

      end

    end

    describe 'put' do

      before(:each) do
        post '/pr.521', {
          :description => 'fredbob'
        }
      end

      it 'simple - manifest only' do

        put '/pr.521', {
          :description => 'this is a test'
        }

        release = Manifest.first

        expect(last_response.ok?).to be true
        expect(release.name).to eq 'pr.521'
        expect(release.description).to eq 'this is a test'
      end

      it 'complex - with application versions' do

          put '/pr.521', {
            :description => 'fredbob',
            :application_versions => {
              :notepad => '1.0',
              :dobby => '0.3.0.126'
            }
          }

          expect(last_response.ok?).to eq true

          result = Manifest.first({:name => 'pr.521'})

          expect(result).to_not be nil
          expect(result.application_versions.size).to eq 2

          expect(result.application_versions[0].application.name).to eq 'notepad'
          expect(result.application_versions[0].value).to eq '1.0'

          expect(result.application_versions[1].application.name).to eq 'dobby'
          expect(result.application_versions[1].value).to eq '0.3.0.126'

      end

    end

    it 'get' do
      post_data = {
        :description => 'fredbob'
      }

      post '/pr.521', post_data
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

      expect(result['application_versions']).to_not be nil
      expect(result['application_versions']).to be_kind_of Array
    end

    it 'delete' do
      post '/pr.521', {
        :description => 'fredbob'
      }

      delete '/pr.521'

      expect(Manifest.collection.size).to eq 0
    end

    describe '/' do |variable|
      before(:each) do
        post '/pr.346', { :description => 'test release'}
      end

      it 'get' do

        get '/'

        expect(last_response.ok?).to eq true

        array = JSON.parse(last_response.body)
        expect(array).to be_kind_of(Array)

        expect(array.size).to eq 1
        expect(array.first['name']).to eq 'pr.346'

      end

    end

  end

end
