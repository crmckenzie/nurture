require_relative '../../spec_helper'

describe Manifests do
  include Rack::Test::Methods

  before(:each) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"

  end

  describe '.add_version' do

    subject {

      Application.create({
        :name => 'fredbob'
        })

    }

    it 'add version' do

      subject.add_version '1.0'

      expect(subject.application_versions.size).to eq 1
      expect(subject.application_versions[0].value).to eq '1.0'

    end

    it 'does not add same version twice' do
      subject.add_version '1.0'
      subject.add_version '1.0'

      expect(subject.application_versions.size).to eq 1
      expect(subject.application_versions[0].value).to eq '1.0'

    end

    it 'can add multiple versions' do
      subject.add_version '1.0'
      subject.add_version '1.1'

      expect(subject.application_versions.size).to eq 2
      expect(subject.application_versions[1].value).to eq '1.1'

    end

    it 'can associate version with manfiest' do
      manifest = Manifest.create({
        :name => 'pr.521'
        })

      subject.add_version '1.0', manifest

      expect(subject.application_versions[0].manifest).to eq manifest

    end

  end

end
