class Environment
  include MongoMapper::Document
  key :name, String

  many :manifests

  timestamps!
end
