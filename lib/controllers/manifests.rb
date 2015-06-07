class Manifests < Sinatra::Base

  before do
  end

  after do
    request.accept.each do | accept |
      case accept
      when true
      else # default to json
        response.body = response.body.to_json unless response.body.kind_of? String
        response.header["Content-Type"] = "application/json"
      end
    end
  end

  get '/' do
    Manifest.all()
  end

  def halt_if_no_application_versions(params)
    versions = params[:application_versions]
    has_versions = versions && versions.keys && versions.keys.size > 0
    halt HttpStatusCodes::FORBIDDEN, {:application_versions => ['at least one application version is required.']} unless has_versions
  end

  def halt_if_applications_do_not_exist(params)
    keys = params[:application_versions].keys

    names = Application
        .where(:name.in => keys)
        .fields(:name)
        .all
        .map {|row| row.name}

    keys.each do |name|
      halt HttpStatusCodes::FORBIDDEN, {:application_versions => ["'#{name}' is not an application."]} if !names.include? name
    end
  end

  def halt_if_released(manifest)
    if (manifest.release)
      halt HttpStatusCodes::FORBIDDEN, {:application_versions => ['manifest has been released']}
    end
  end

  def create_or_get_application_version(application, manifest, version)

    version
  end

  post '/' do
    halt_if_no_application_versions params
    halt_if_applications_do_not_exist params

    manifest = Manifest.create({
      :name => params[:name],
      :description => params[:description],
      :status => :in_progress
    })

    halt HttpStatusCodes::FORBIDDEN, manifest.errors unless manifest.valid?

    if params[:application_versions]
      params[:application_versions].each do |key, value|
        app = Application.first({
          :name => key
          })

        version = app.application_versions.first({
          :value => value
          })

        version = ApplicationVersion.create({
          :value => value,
          :application => app,
          :manifest => manifest
          }) if version.nil?

      end

    end

  end


  put '/:name' do
    manifest = Manifest.first({:name => params[:name]})
    halt_if_released manifest
    halt_if_applications_do_not_exist params if params[:application_versions]

    manifest.description = params[:description] if params[:description]
    manifest.save

    if params[:application_versions]

      manifest.application_versions.each do |application_version|
        application_version.manifest = nil
        application_version.save
      end

      params[:application_versions].each do |key, value|
        app = Application.first({
          :name => key
          })

        version = app.application_versions.first({
          :value => value
          })

        version = ApplicationVersion.create({
          :value => value,
          :application => app,
          :manifest => manifest
          }) if version.nil?
      end

    end

  end

  delete '/:name' do
    manifest = Manifest.first({:name => params[:name]})
    halt_if_released manifest
    manifest.destroy
  end

  get '/:name' do
    status 200
    body Manifest.first({:name => params[:name]})
  end

end
