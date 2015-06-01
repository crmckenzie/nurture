class Environment
  include MongoMapper::Document
  key :name, String

  timestamps!
end
