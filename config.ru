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

map'/api/v1/' do
  run Nurture::Api
end
