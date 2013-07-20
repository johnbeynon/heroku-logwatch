require 'bundler'
Bundler.require

STDOUT.sync = true

class App < Sinatra::Base

  GEOIP_FILE = File.join(File.dirname(__FILE__), 'lib', 'geoip', 'GeoLiteCity.dat')

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  helpers do
    # Heroku API
    def api
      halt(401) unless request.env['bouncer.token']
      Heroku::API.new(api_key: request.env['bouncer.token'])
    end
  end

  get '/' do
    @apps = api.get_apps.body
    haml GeoIP.new(GEOIP_FILE).city('heroku.com').to_hash.to_s
  end

end

