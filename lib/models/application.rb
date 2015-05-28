class Application
  include MongoMapper::Document
  key :name, String
  key :version, String

  timestamps!
end
