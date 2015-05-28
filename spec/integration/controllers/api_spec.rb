require_relative '../../spec_helper'

describe Api do
  include Rack::Test::Methods

  before(:all) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

  after(:all) do
  end

  after(:each) do |x|
    puts x.full_description

    Dir.mkdir 'tmp' if ! Dir.exists? 'tmp'

    next if last_response.ok?

    filename = 'tmp/api-test.html'
    File.delete filename if File.exists? filename


    File.open('tmp/api-test.html', 'w') do |file|
      file.write last_response.body
    end

    #system "open #{filename}"
  end

  subject {Api.new }

  # required by rack/test
  def app
    subject
  end

  describe '/manifests' do

    before(:each) do
      Manifest.collection.remove
    end

    it 'post' do
      post '/manifests', {
        :name => 'pr.521',
        :description => 'fredbob'
      }

      release = Manifest.first

      expect(last_response.ok?).to be true
      expect(release.name).to eq 'pr.521'
      expect(release.description).to eq 'fredbob'

    end

    it 'get' do
      post_data = {
        :name => 'pr.521',
        :description => 'fredbob'
      }

      post '/manifests', post_data

      get '/manifests'

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
      post '/manifests', {
        :name => 'pr.521',
        :description => 'fredbob'
      }

      delete '/manifests', { :name => 'pr.521' }

      expect(Manifest.collection.size).to eq 0

    end

    describe '/manifests/:name/applications' do

      before(:each) do

        body = {
          :name => 'pr.346',
          :description => 'test release'
        }

        post '/manifests', body

      end

      it 'post' do

        body = {
          :notepad => '1.0',
          :dobby => '0.3.0.126'
        }

        post '/manifests/pr.346/applications', body

        expect(last_response.ok?).to eq true

        result = Manifest.first({:name => 'pr.346'})

        expect(result).to_not be nil
        expect(result.application_ids.size).to eq 2
        expect(result.applications.size).to eq 2

        expect(result.applications[0].name).to eq 'notepad'
        expect(result.applications[0].version).to eq '1.0'

        expect(result.applications[1].name).to eq 'dobby'
        expect(result.applications[1].version).to eq '0.3.0.126'
      end

    end

  end


end
