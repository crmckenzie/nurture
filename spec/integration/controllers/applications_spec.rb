require_relative '../../spec_helper'

describe Applications do
  include Rack::Test::Methods

  before(:all) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

  subject { Applications }

  # required by rack/test
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

        application = Application.first({:name => 'app-1'})

        expect(last_response.ok?).to be true
        expect(application.name).to eq 'app-1'
        expect(application.type).to eq 'web service'
        expect(application.platform).to eq 'windows'
        expect(application.tags).to eq ['tag1','tag2','tag3','tag4','tag5']
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
  #
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

end
