class Manifest
  include MongoMapper::Document

  key :name, String
  key :description, String
  key :environment, String

  many :application_versions

  def serializable_hash(options = {})
    result = super({:include => :application_versions}.merge(options))
    result
  end

  timestamps!
end
