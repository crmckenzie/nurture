require_relative '../../spec_helper'

describe Manifest do

  before(:each) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

  describe 'save' do

    it 'saves a simple Manifest' do

      manifest = Manifest.new
      manifest.name = 'pr.346'
      manifest.save

      result = Manifest.first({:name => 'pr.346'})

      expect(result).to_not be nil
      expect(result.name).to eq 'pr.346'

    end

    describe 'relationships' do

      let(:notepad) {
        notepad = Application.new
        notepad.name = 'notepad'
        notepad.save

        version = ApplicationVersion.new
        version.value = '1.2.3'
        version.application = notepad
        version.save

        version
      }

      let(:dobby) {
        dobby = Application.new
        dobby.name = 'dobby'
        dobby.save

        version = ApplicationVersion.new
        version.application = dobby
        version.value = '2.3.4'
        version.save

        version
      }

      subject {

        manifest = Manifest.new
        manifest.name = 'pr.346'
        manifest.save

        dobby.manifest = manifest
        notepad.manifest = manifest

        dobby.save
        notepad.save  

        result = Manifest.first({:name => 'pr.346'})

        result
      }

      it '.application_versions' do

        expect(subject.application_versions.size).to eq 2
        expect(subject.application_versions).to include(dobby)
        expect(subject.application_versions).to include(notepad)

      end

    end

  end

end
