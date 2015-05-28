class Manifest
  include MongoMapper::Document

  key :name, String
  key :description, String
  key :environment, String

  key :application_ids, Array

  many :applications, :in => :application_ids, :class_name => 'Application'

  def serializable_hash(options = {})
    result = super({:except => :application_ids, :include => :applications}.merge(options))
    result
  end

  timestamps!
end
