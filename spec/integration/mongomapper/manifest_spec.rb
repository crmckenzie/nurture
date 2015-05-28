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
        notepad.version = '1.2.3'
        notepad.save

          notepad
      }

      let(:dobby) {
        dobby = Application.new
        dobby.name = 'dobby'
        dobby.version = '2.3.4'
        dobby.save

        dobby
      }

      subject {

        manifest = Manifest.new
        manifest.name = 'pr.346'
        manifest.application_ids.push dobby.id
        manifest.application_ids.push notepad.id
        manifest.save

        result = Manifest.first({:name => 'pr.346'})

        result
      }

      it '.application_ids' do

        expect(subject.application_ids.size).to eq 2
        expect(subject.application_ids).to include(dobby.id)
        expect(subject.application_ids).to include(notepad.id)

      end


      it '.applications' do

        expect(subject.applications.size).to eq 2

        names = subject.applications.map {|row| row.name}

        expect(names).to include('notepad')
        expect(names).to include('dobby')

      end

    end




  end

end
