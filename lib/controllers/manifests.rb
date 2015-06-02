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

  post '/' do
    manifest_data = {
      :name => params[:name],
      :description => params[:description]
    }
    manifest = Manifest.create manifest_data
    manifest.save

    if params[:application_versions]
      params[:application_versions].each do |key, value|
        hash = {:name => key }
        app = Application.create hash
        app.save

        hash = {:value => value }
        version = ApplicationVersion.create hash
        version.application = app
        version.manifest = manifest
        version.save
      end

    end

  end

  put '/:name' do
    manifest = Manifest.first({:name => params[:name]})
    manifest.description = params[:description] if params[:description]
    manifest.save

    if params[:application_versions]
      manifest.application_versions.each do |application_version|
        application_version.manifest = nil
        application_version.save
      end

      params[:application_versions].each do |key, value|
        hash = {:name => key }
        app = Application.create hash
        app.save

        hash = {:value => value }
        version = ApplicationVersion.create hash
        version.application = app
        version.manifest = manifest
        version.save
      end

    end

  end

  delete '/:name' do
    name = params[:name]
    item = Manifest.first({:name => name})
    item.destroy
  end

  get '/:name' do
    status 200
    body Manifest.first({:name => params[:name]})
  end

end
