require_relative '../../spec_helper'

  describe Applications do
    include Rack::Test::Methods

    before(:each) do
      client = Mongo::MongoClient.new
      db = client.db 'nurture-tests'
      db.command({:dropDatabase => 1})

      MongoMapper.database = "nurture-tests"
    end

    subject { Applications }

    def app
      subject
    end

    before(:each) do
      Application.collection.remove
    end

    describe '/' do

      describe 'post' do

        it 'simple' do
          post '/', {
            :name => 'app-1',
            :type => 'web service',
            :platform => 'windows',
            :tags => ['tag1','tag2','tag3','tag4','tag5']
            }

          expect(last_response.ok?).to be true

          application = Application.first({:name => 'app-1'})
          expect(application.name).to eq 'app-1'
          expect(application.type).to eq 'web service'
          expect(application.platform).to eq 'windows'
          expect(application.tags).to eq ['tag1','tag2','tag3','tag4','tag5']
        end

        it 'name is required' do
          post '/', {
            :description => 'fredbob',
          }

          expect(last_response.ok?).to be false
          expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

          json = JSON.parse(last_response.body)
          expect(json['name'][0]).to eq "can't be blank"

        end

        it 'names must be unique' do
          post '/', {
            :name => 'fredbob'
          }
          post '/', {
            :name => 'fredbob',
          }

          expect(last_response.ok?).to eq false
          expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

          json = JSON.parse(last_response.body)
          expect(json['name'][0]).to eq 'has already been taken'
        end

      end

      it 'get' do

        post '/', {
                  :name => 'app-1',
                  :type => 'web service',
                  :platform => 'windows',
                  :tags => ['tag1','tag2','tag3','tag4','tag5']
                  }

        get '/'

        expect(last_response.ok?).to eq true
        array = JSON.parse(last_response.body)
        result = array.first

        expect(result['name']).to eq 'app-1'
      end

  end

  describe '/:name' do

    before(:each) do
      post '/', {
                :name => 'app-1',
                :type => 'web service',
                :platform => 'windows',
                :tags => ['tag1','tag2','tag3','tag4','tag5']
                }

    end

    it 'get' do

      get '/app-1'

      expect(last_response.ok?).to be true

      result = JSON.parse(last_response.body)

      expect(result['name']).to eq 'app-1'
    end

    describe 'put' do

      before(:each) do
        post '/', {
                  :name => 'app-1',
                  :type => 'web service',
                  :platform => 'windows',
                  :tags => ['tag1','tag2','tag3','tag4','tag5']
                  }
      end

      it 'basic update' do

        put '/app-1', {
          :type => 'windows service',
          :platform => 'win32',
          :tags => ['tag6']
        }

        expect(last_response.ok?).to be true

        record = Application.first({:name => 'app-1'})

        expect(record['type']).to eq 'windows service'
        expect(record['platform']).to eq 'win32'
        expect(record['tags']).to eq ['tag6']

      end

    end

    it 'delete' do

      delete '/app-1'

      expect(last_response.ok?).to be true

      expect(Application.collection.size).to eq 0
    end

  end

  describe '/:name/versions' do

    before(:each) do
      julia = Application.create({:name => 'julia'})
      julia.add_version '1.0'
      julia.add_version '1.1'
      julia.add_version '1.2'
    end

    it 'get' do

      get '/julia/versions'

      expect(last_response.ok?).to eq true

      json = JSON.parse(last_response.body)

      expect(json.size).to eq 3

      expect(json).to include '1.0'
      expect(json).to include '1.1'
      expect(json).to include '1.2'

    end
  end

  describe '/:name/releases' do

    before(:each) do
      julia = Application.create({:name => 'julia'})

      manifest = Manifest.create({:name => 'pr.123'})
      manifest.add_version 'julia', '1.0'
      manifest.perform_release

      manifest = Manifest.create({:name => 'pr.234' })
      manifest.add_version 'julia', '1.1'
      manifest.perform_release

    end

    it 'get' do

      get '/julia/releases'

      expect(last_response.ok?).to eq true

      json = JSON.parse(last_response.body)

      expect(json.size).to eq 2

      releases = Release.sort(:created_at).all

      expect(json[0]['manifest']).to eq 'pr.123'
      expect(json[1]['manifest']).to eq 'pr.234'

      expect(json[0]['version']).to eq '1.0'
      expect(json[1]['version']).to eq '1.1'

    end

  end

end
