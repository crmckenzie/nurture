require 'sinatra'
require 'mongo_mapper'

module Nurture
  def self.root
    path_to_current_file = File.dirname(File.expand_path(__FILE__))
    root = File.expand_path('..', path_to_current_file)
    root
  end

  def self.site_root(request)
    "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end

root = Nurture::root

require_relative './nurture/version'
#require_relative './mixins/settings'
#require_relative './mixins/logging'

Dir["#{root}/lib/mixins/*.rb"].each { |file| require file }
Dir["#{root}/lib/errors/*.rb"].each { |file| require file }
Dir["#{root}/lib/models/*.rb"].each { |file| require file }
Dir["#{root}/lib/transactions/*.rb"].each { |file| require file }
Dir["#{root}/lib/controllers/*.rb"].each { |file| require file }
Dir["#{root}/lib/middleware/*.rb"].each { |file| require file }
