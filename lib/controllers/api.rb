class Api < Sinatra::Base

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

  get '/manifests' do
    Manifest.all()
  end

  post '/manifests' do
    Manifest.create params
  end

  put '/manifests' do

  end

  delete '/manifests' do
    name = params[:name]
    item = Manifest.first({:name => name})
    item.destroy
  end

  post '/manifests/:name/applications' do
    applications = params.clone
    applications.delete 'name'
    applications.delete 'splat'
    applications.delete 'captures'

    name = params[:name]
    manifest = Manifest.first({:name => name})
    manifest.application_ids.clear

    applications.each do |key, value|
      app = Application.new
      app.name = key
      app.version = value
      app.save

      manifest.application_ids.push app.id
    end

    manifest.save
    manifest

  end

end
