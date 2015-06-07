require_relative '../../spec_helper'

describe Manifests do
  include Rack::Test::Methods

  before(:each) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"

    Application.create({:name => 'notepad'})
    Application.create({:name => 'dobby'})
    Application.create({:name => 'iterm2'})
    Application.create({:name => 'git'})
    Application.create({:name => 'ruby'})
  end

  subject { Manifests }

  # required by rack/test
  def app
    subject
  end

  describe '/' do

    describe 'post' do

      it 'can post with application versions' do

          post '/', {
            :name => 'pr.521',
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

      it 'name is required' do
        post '/', {
          :description => 'fredbob',
          :application_versions => {
            :notepad => '1.0',
          }
        }

        release = Manifest.first

        expect(last_response.ok?).to be false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['name'][0]).to eq "can't be blank"

      end

      it 'names must be unique' do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob',
          :application_versions => {
            :notepad => '1.0',
          }
        }
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob',
          :application_versions => {
            :notepad => '1.0',
          }
        }


        expect(last_response.ok?).to eq false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['name'][0]).to eq 'has already been taken'
      end

      it 'application versions are required.' do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob'
        }

        release = Manifest.first

        expect(last_response.ok?).to be false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['application_versions'][0]).to eq 'at least one application version is required.'

      end

      it 'application must exist' do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob',
          :application_versions => {
            :fredbob => '1.0.0'
          }
        }

        release = Manifest.first

        expect(last_response.ok?).to be false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['application_versions'][0]).to eq "'fredbob' is not an application."

      end

      it 'does not create duplicate application versions' do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob',
          :application_versions => {
            :dobby => '1.0'
          }
        }

        post '/', {
          :name => 'pr.522',
          :description => 'fredbob',
          :application_versions => {
            :dobby => '1.0'
          }
        }

        app = Application.first({:name => 'dobby'})
        expect(app.application_versions.count).to eq 1

      end

    end

    it 'get' do
      post '/', {
        :name => 'pr.346',
        :description => 'test release',
        :application_versions => {
          :notepad => '1.0.3'
        }
      }

      get '/'

      expect(last_response.ok?).to eq true

      array = JSON.parse(last_response.body)
      expect(array).to be_kind_of(Array)

      expect(array.size).to eq 1
      expect(array.first['name']).to eq 'pr.346'

    end

  end


  describe '/:name' do

    it 'get' do

      post '/', {
        :name => 'pr.521',
        :description => 'fredbob',
        :application_versions => {
          'notepad' => '1.0.3'
        }
      }

      expect(last_response.ok?).to be true

      get '/pr.521'

      expect(last_response.ok?).to be true

      result = JSON.parse(last_response.body)

      expect(result['name']).to eq 'pr.521'
      expect(result['description']).to eq 'fredbob'
      expect(result['created_at']).to_not be nil
      expect(result['updated_at']).to_not be nil
      expect(result['id']).to_not be nil

      expect(result['application_versions']).to_not be nil
      expect(result['application_versions']).to be_kind_of Array
    end

    describe 'put' do

      before(:each) do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob',
          :application_versions => {
            :notepad => '1.0',
            :dobby => '0.3.0.126'
          }
        }
      end

      it 'does not update application versions if they are not specified' do
        put '/pr.521', {
          :description => 'this is a test'
        }

        expect(last_response.ok?).to be true

        release = Manifest.first
        expect(release.name).to eq 'pr.521'
        expect(release.description).to eq 'this is a test'
        expect(release.application_versions.size).to eq 2
      end

      it 'updates application versions' do

          put '/pr.521', {
            :description => 'fredbob',
            :application_versions => {
              :iterm2 => '3.0',
              :ruby => '2.2.1',
              :git => '1.9.0'
            }
          }

          expect(last_response.ok?).to eq true

          result = Manifest.first({:name => 'pr.521'})

          expect(result).to_not be nil
          expect(result.application_versions.size).to eq 3

          expect(result.application_versions[0].application.name).to eq 'iterm2'
          expect(result.application_versions[0].value).to eq '3.0'

          expect(result.application_versions[1].application.name).to eq 'ruby'
          expect(result.application_versions[1].value).to eq '2.2.1'

          expect(result.application_versions[2].application.name).to eq 'git'
          expect(result.application_versions[2].value).to eq '1.9.0'
      end

      it 'does not create duplicate application versions' do
        put '/pr.521', {
          :description => 'fredbob',
          :application_versions => {
            :dobby => '0.3.0.126'
          }
        }

        post '/pr.521', {
          :description => 'fredbob',
          :application_versions => {
            :dobby => '0.3.0.126'
          }
        }

        app = Application.first({:name => 'dobby'})
        expect(app.application_versions.count).to eq 1

      end

      it 'cannot be released' do
        manifest = Manifest.first({:name => 'pr.521'})
        manifest.release = Release.create()
        manifest.save

        put '/pr.521', {
          :description => 'fredbob'
        }

        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['application_versions'][0]).to eq 'manifest has been released'

      end

      it 'applications must exist' do

        put '/pr.521', {
          :description => 'fredbob',
          :application_versions => {
            :fredbob => '1.0'
          }
        }

        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['application_versions'][0]).to eq  "'fredbob' is not an application."
      end

    end

    describe 'delete' do
      before(:each) do
        post '/', {
          :name => 'pr.521',
          :description => 'fredbob',
          :application_versions => {
            :notepad => '1.0.3'
          }
        }

      end

      it 'removes the manifest' do

        delete '/pr.521'

        expect(Manifest.collection.size).to eq 0
      end

      it 'returns FORBIDDEN if the status is released' do
        manifest = Manifest.first({:name => 'pr.521'})
        manifest.release = Release.create()
        manifest.save

        delete '/pr.521'

        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['application_versions'][0]).to eq 'manifest has been released'
      end
    end
  end

end
