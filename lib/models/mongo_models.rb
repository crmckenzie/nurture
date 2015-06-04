class Application
  include MongoMapper::Document
  key :name, String

  many :application_versions

  timestamps!
end

class ApplicationVersion
  include MongoMapper::Document

  key :value, String

  belongs_to :application
  belongs_to :manifest

  timestamps!
end

class Environment
  include MongoMapper::Document
  key :name, String

  many :manifests

  timestamps!
end

class Manifest
  include MongoMapper::Document

  key :name, String
  key :description, String

  many :application_versions

  belongs_to :environment
  belongs_to :release

  def serializable_hash(options = {})
    result = super({:include => :application_versions}.merge(options))
    result
  end

  timestamps!
end

class Release
  include MongoMapper::Document

  many: manifests

  timestamps!
end
