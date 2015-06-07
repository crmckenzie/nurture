class Releases < Sinatra::Base

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

  post '/' do
    release = Release.create
    params[:manifests].each do |row|
      manifest = Manifest.first({:name => row})
      manifest.release = release
      manifest.save
    end

    status 200
    body({:id => release.id.to_s})
  end

  get '/' do
    Release.all()
  end

  get '/:id' do
    status 200
    body Release.first({:id => params[:id]})
  end

end
