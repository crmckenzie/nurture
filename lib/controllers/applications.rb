class Applications < Sinatra::Base

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
    Application.all()
  end

  post '/' do
    data = {
      :name => params[:name],
      :description => params[:description],
      :type => params[:type],
      :platform => params[:platform],
      :tags => params[:tags] || []
    }

    record = Application.create data

    halt HttpStatusCodes::FORBIDDEN, record.errors unless record.valid?

  end

  get '/:name/versions' do
    application = Application.first({:name => params[:name]})
    halt HttpStatusCodes::NOT_FOUND unless application
    values = application.application_versions.map {|version| version.value}
    values
  end

  get '/:name/releases' do
    application = Application.first({:name => params[:name]})
    halt HttpStatusCodes::NOT_FOUND unless application

    versions = application.application_versions
    releases = versions.map {|version|
      {
        :manifest => version.manifest.name,
        :version => version.value,
        :created_at => version.manifest.release.created_at
      }
    }

    body releases
  end

  get '/:name' do
    status 200
    body Application.first({:name => params[:name]})
  end

  put '/:name' do
    record = Application.first({:name => params[:name]})

    record.description = params[:description]
    record.type = params[:type]
    record.platform = params[:platform]
    record[:tags] = params[:tags] || []

    record.save

    halt HttpStatusCodes::FORBIDDEN, record.errors unless record.valid?

  end

  delete '/:name' do
    name = params[:name]
    item = Application.first({:name => name})
    item.destroy
  end

end
