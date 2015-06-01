class Application
  include MongoMapper::Document
  key :name, String

  many :application_versions

  timestamps!
end
