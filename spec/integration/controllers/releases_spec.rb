require_relative '../../spec_helper'

describe Manifests do
  include Rack::Test::Methods

  before(:each) do
    client = Mongo::MongoClient.new
    db = client.db 'nurture-tests'
    db.command({:dropDatabase => 1})

    MongoMapper.database = "nurture-tests"
  end

end
