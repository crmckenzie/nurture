class Api < Sinatra::Base

  before do
  end

  error do
    binding.pry
    puts "An error occurred: #{env['sinatra.error']}"
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
    manifest_data = {
      :name => params[:name],
      :description => params[:description]
    }
    manifest = Manifest.create manifest_data

    if params[:applications]

      params[:applications].each do |key, value|
        hash = {:name => key, :version => value}
        app = Application.create hash
        app.save

        manifest.application_ids.push app.id
      end

    end

    manifest.save
  end

  put '/manifests' do
    manifest = Manifest.first({:name => params[:name]})
    manifest.description = params[:description] if params[:description]

    if params[:applications]
      manifest.application_ids.clear

      params[:applications].each do |key, value|
        hash = {:name => key, :version => value}
        app = Application.create hash
        app.save

        manifest.application_ids.push app.id
      end

    end

    manifest.save
  end

  delete '/manifests' do
    name = params[:name]
    item = Manifest.first({:name => name})
    item.destroy
  end

  get '/manifests/:name' do
    Manifest.first({:name => params[:name]})
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
