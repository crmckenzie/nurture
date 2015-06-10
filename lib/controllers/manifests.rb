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

  post '/' do
    halt_if_no_application_versions params
    halt_if_applications_do_not_exist params

    manifest = Manifest.create({
      :name => params[:name],
      :description => params[:description]
    })

    halt HttpStatusCodes::FORBIDDEN, manifest.errors unless manifest.valid?

    manifest.sync_versions params[:application_versions]

  end


  put '/:name' do
    manifest = Manifest.first({:name => params[:name]})
    halt_if_released manifest
    halt_if_applications_do_not_exist params if params[:application_versions]

    manifest.description = params[:description] if params[:description]
    manifest.save

    manifest.sync_versions params[:application_versions]

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
