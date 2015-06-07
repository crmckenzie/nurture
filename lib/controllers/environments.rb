class Environments < Sinatra::Base

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
    Environment.all()
  end

  post '/' do
    halt HttpStatusCodes::FORBIDDEN, {:reason => "'prod' is managed by the system."} if params[:name] == 'prod'

    hash = {:name => params[:name]}
    environment = Environment.create hash
    environment.save

    if params[:manifests]
      params[:manifests].each do |name|
        manifest = Manifest.first({:name => name})
        manifest.environment = environment
        manifest.save
      end
    end

  end

  put '/:name' do
    halt HttpStatusCodes::FORBIDDEN, {:reason => "'prod' is managed by the system."} if params[:name] == 'prod'

    environment = Environment.first({:name => params[:name]})

    if params[:manifests]
      environment.manifests.each do |manifest|
        manifest.environment = nil
        manifest.save
      end

      params[:manifests].each do |name|
        manifest = Manifest.first({:name => name})
        manifest.environment = environment
        manifest.save
      end
    end
  end

  delete '/:name' do
    halt HttpStatusCodes::FORBIDDEN, {:reason => "'prod' is managed by the system."} if params[:name] == 'prod'

    name = params[:name]
    item = Environment.first({:name => name})
    item.destroy
  end

  get '/:name' do
    environment = Environment.first(:name => params[:name])
    if environment.nil?
      halt 404 unless params[:name] == 'prod'

      environment = Environment.create({
        :name => 'prod',
        :manifests => []
        })
    end

    status 200
    body environment
  end

end
