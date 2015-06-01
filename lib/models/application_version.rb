class ApplicationVersion
  include MongoMapper::Document

  key :value, String

  belongs_to :application
  belongs_to :manifest

  timestamps!
end
