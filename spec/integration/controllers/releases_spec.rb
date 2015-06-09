require_relative '../../spec_helper'

describe Releases do
  include Rack::Test::Methods

  before(:each) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"

    dobby   = Application.create({:name => 'dobby'})
    julia   = Application.create({:name => 'julia'})
    nurture = Application.create({:name => 'nurture'})

    Manifest.create({
      :name => 'pr.123',
      :application_versions => [
        {:application => dobby, :value => '1.0'},
        {:application => julia, :value => '1.0'}
      ]
    })
    Manifest.create({
      :name => 'pr.234',
      :application_versions => [
        { :application => nurture, :value => '1.0'}
      ]
    })
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

      it 'applies application versions from manifest to release' do

        versions = release.application_versions.map do |row|
          {
            :name => row.application.name,
            :version => row.value
          }
        end

        expect(versions.size).to eq 3
        expect(versions[0][:name]).to eq 'dobby'
        expect(versions[1][:name]).to eq 'julia'
        expect(versions[2][:name]).to eq 'nurture'

        expect(versions[0][:version]).to eq '1.0'
        expect(versions[1][:version]).to eq '1.0'
        expect(versions[2][:version]).to eq '1.0'

      end

      it 'applies previously released application versions to release' do
        nurture = Application.first({:name => 'nurture'})

        manifest = Manifest.create({
          :name => 'pr.345',
          :application_versions => [
            { :application => nurture, :value => '1.0.1'}
          ]
        })

        expect(manifest.errors.size).to eq 0

        post '/', {
          :manifests => ['pr.345']
        }

        release = Release.sort(:created_at).last
        versions = release.application_versions.map do |row|
          {
            :name => row.application.name,
            :version => row.value
          }
        end

        expect(versions.size).to eq 3
        expect(versions[0][:name]).to eq 'dobby'
        expect(versions[1][:name]).to eq 'julia'
        expect(versions[2][:name]).to eq 'nurture'

        expect(versions[0][:version]).to eq '1.0'
        expect(versions[1][:version]).to eq '1.0'
        expect(versions[2][:version]).to eq '1.0.1'

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
