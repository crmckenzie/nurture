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

  put '/' do
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

  delete '/' do
    name = params[:name]
    item = Manifest.first({:name => name})
    item.destroy
  end

  get '/:name' do
    Manifest.first({:name => params[:name]})
  end


end
