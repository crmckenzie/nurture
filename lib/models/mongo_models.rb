class Application
  include MongoMapper::Document
  key :name, String
  key :type, String
  key :platform, String
  key :tags, Array

  many :application_versions

  def add_version(version, manifest = nil)

    count = self.application_versions
      .where({:value => version})
      .count

    version = ApplicationVersion.create({
      :application => self,
      :value => version,
      :manifest => manifest
      }) if count == 0
  end

  timestamps!
  userstamps!
end

class ApplicationVersion
  include MongoMapper::Document

  key :value, String

  belongs_to :application
  belongs_to :manifest

  timestamps!
  userstamps!
end

class Environment
  include MongoMapper::Document
  key :name, String

  many :manifests

  def serializable_hash(options = {})
    result = super(options)
    result[:manifests] = manifests.map {|row| row.name }
    result
  end

  timestamps!
  userstamps!
end

class Manifest
  include MongoMapper::Document

  key :name, String, :required => true, :unique => true
  key :description, String

  def status
    return :released if release
    return :in_progress
  end


  many :application_versions

  belongs_to :environment
  belongs_to :release


  def sync_versions(versions)
    if versions

      self.application_versions.each do |version|
        version.manifest = nil
        version.save
      end

      versions.each do |name, version|
        app = Application.first({
          :name => name
          })

        app.add_version version, self
      end

    end
  end

  def serializable_hash(options = {})
    result = super({:include => :application_versions}.merge(options))
    result
  end

  timestamps!
  userstamps!
end

class Release
  include MongoMapper::Document

  many :manifests

  def serializable_hash(options = {})
    result = super(options)
    result[:manifests] = manifests.map {|row| row.name }
    result
  end

  timestamps!
  userstamps!
end
