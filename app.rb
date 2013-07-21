require 'bundler'
Bundler.require

STDOUT.sync = true

require_relative 'lib/logplex_parser'

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

  get '/?:app?' do
    @apps = api.get_apps.body
    haml :index
  end

  get '/:app/markers' do
    # TODO: Move to own route?
    logplexparse = HerokuLogwatch::LogplexParser.new(request.env['bouncer.token'], params['app'])
    logplexparse.parse do |entry|
      raise entry.inspect
    #  # TODO: Geocode remote IP
    #  # TODO: Pusher marker onto MAP
    end
    haml ''

  end

end

