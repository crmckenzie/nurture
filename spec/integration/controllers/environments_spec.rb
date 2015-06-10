require_relative '../../spec_helper'

describe Environments do
  include Rack::Test::Methods

  before(:each) do
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

      it 'cannot post prod environment' do
        post '/', {:name => 'prod'}

        expect(last_response.ok?).to eq false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['reason']).to eq "'prod' is managed by the system."

      end

    end

    it 'get' do

      post '/', {:name => 'uat-team-a'}
      environment = Environment.first({:name => 'uat-team-a'})
      Manifest.create({
        :name => 'pr.123',
        :environment => environment
        })

      Manifest.create({
        :name => 'pr.234',
        :environment => environment
        })

      get '/'

      expect(last_response.ok?).to eq true
      array = JSON.parse(last_response.body)
      result = array.first

      expect(result['name']).to eq 'uat-team-a'
      manifests = result['manifests']

      expect(manifests).to include 'pr.123'
      expect(manifests).to include 'pr.234'
    end

  end

  describe '/:name' do

    describe 'get' do

      before(:each) do
        post '/', {:name => 'uat-team-a'}

        environment = Environment.first({:name => 'uat-team-a'})
        Manifest.create({
          :name => 'pr.123',
          :environment => environment
          })

        Manifest.create({
          :name => 'pr.234',
          :environment => environment
          })

      end

      it 'get' do

        get '/uat-team-a'

        expect(last_response.ok?).to be true

        result = JSON.parse(last_response.body)

        expect(result['name']).to eq 'uat-team-a'

        manifests = result['manifests']

        expect(manifests).to include 'pr.123'
        expect(manifests).to include 'pr.234'
      end

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

      it 'cannot update prod environment' do
        put '/prod', {
          :manifests => ['pr.345', 'pr.567']
        }

        expect(last_response.ok?).to eq false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['reason']).to eq "'prod' is managed by the system."

      end

      it 'creates prod environment on demand' do

        get '/prod'

        expect(last_response.ok?).to eq true

        json = JSON.parse(last_response.body)
        expect(json['name']).to eq 'prod'
        expect(json['manifests']).to eq []

      end

      it 'returns NOT_FOUND for non-existent environments' do

        get '/fredbob'

        expect(last_response.status).to eq HttpStatusCodes::NOT_FOUND

      end

    end

    describe 'delete' do
      it 'happy path' do
        post '/', {:name => 'uat-team-a'}

        delete '/uat-team-a'

        expect(last_response.ok?).to be true

        expect(Manifest.collection.size).to eq 0
      end

      it 'cannot delete prod environment' do
        delete '/prod'

        expect(last_response.ok?).to eq false
        expect(last_response.status).to eq HttpStatusCodes::FORBIDDEN

        json = JSON.parse(last_response.body)
        expect(json['reason']).to eq "'prod' is managed by the system."

      end

    end

    describe '/application_versions' do

      describe 'get' do

        before(:each) do

          post '/', {:name => 'uat-team-a'}

          expect(last_response.ok?).to eq true

          environment = Environment.first({:name => 'uat-team-a'})

          dobby = Application.create({:name => 'dobby'})
          julia = Application.create({:name => 'julia'})

          manifest = environment.create_manifest 'pr.123'
          dobby_version = dobby.add_version '1.0', manifest
          julia_version = julia.add_version '1.0', manifest

          manifest.perform_release

          manifest = environment.create_manifest 'pr.234'
          manifest.add_version 'julia', '1.0.1'

        end

        it 'returns prod + manifest application version overrides' do

          get '/uat-team-a/application_versions'

          expect(last_response.ok?).to eq true

          versions = JSON.parse(last_response.body)

          expect(versions.size).to eq 2

          expect(versions[0]['name']).to eq 'julia'
          expect(versions[1]['name']).to eq 'dobby'

          expect(versions[0]['version']).to eq '1.0.1'
          expect(versions[1]['version']).to eq '1.0'

        end

        it '/app_name' do
          get '/uat-team-a/application_versions/julia'

          puts last_response.body
          expect(last_response.ok?).to eq true

          versions = JSON.parse(last_response.body)

          expect(versions['name']).to eq 'julia'
          expect(versions['version']).to eq '1.0.1'

        end


      end
    end

  end

end
