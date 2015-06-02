class Manifest
  include MongoMapper::Document

  key :name, String
  key :description, String

  many :application_versions

  belongs_to :environment

  def serializable_hash(options = {})
    result = super({:include => :application_versions}.merge(options))
    result
  end

  timestamps!
end
