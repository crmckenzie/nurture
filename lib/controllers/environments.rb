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
    environment = Environment.create params
    environment.save
  end

  put '/' do
    environment = Environment.first({:name => params[:name]})
    environment.save
  end

  delete '/' do
    name = params[:name]
    item = Environment.first({:name => name})
    item.destroy
  end

  get '/:name' do
    Environment.first({:name => params[:name]})
  end

end
