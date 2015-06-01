require './lib/dependencies'

configure do

end

configure :development do
  require 'pry'
  require 'sinatra/reloader'
  register Sinatra::Reloader
  use Rack::Reloader
  use Rack::ShowExceptions
end

map'/api/v1/manifests' do
  run Manifests
end

map '/api/v1/environments' do
  run Environments
end
