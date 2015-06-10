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

  def forbidden(reason)
    halt HttpStatusCodes::FORBIDDEN, {:reason => reason}
  end

  def forbid_prod(params)
    forbidden "'prod' is managed by the system." if params[:name] == 'prod'
  end

  post '/' do
    forbid_prod params

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
    forbid_prod params

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
    forbid_prod params

    name = params[:name]
    item = Environment.first({:name => name})
    item.destroy
  end

  get '/:name/application_versions' do
    environment = Environment.first({:name => params[:name]})
    halt HttpStatusCodes::NOT_FOUND unless environment


    env_versions = []
    environment.manifests.each do |manifest|
      manifest.application_versions.each do |app_version|
        env_versions.push({
          :name => app_version.application.name,
          :version => app_version.value
        })
      end
    end

    release = Release.sort(:created_at).last

    prod_versions = []
    prod_versions = release.application_versions.map do |version|
      {
        :name => version.application.name,
        :version => version.value
      }
    end if release

    prod_versions.each do |prod_version|
      env_versions.push prod_version unless env_versions.detect {|row| row[:name] == prod_version[:name]}
    end

    status 200
    body env_versions
  end

  get '/:name' do
    environment = Environment.first(:name => params[:name])

    halt HttpStatusCodes::NOT_FOUND if environment.nil? unless params[:name] == 'prod'

    environment = Environment.create({
      :name => 'prod'
      }) if environment.nil?

    status HttpStatusCodes::SUCCESS
    body environment
  end


end
