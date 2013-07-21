require 'bundler'
Bundler.require

require 'pusher'

STDOUT.sync = true
$stdout.sync = true

require_relative 'lib/logplex_parser'

class App < Sinatra::Base

  GEOIP_FILE = File.join(File.dirname(__FILE__), 'lib', 'geoip', 'GeoLiteCity.dat')

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  helpers do
    def api
      halt(401) unless request.env['bouncer.token']
      Heroku::API.new(api_key: request.env['bouncer.token'])
    end
  end

  get '/?:app?' do
    @app = params["app"]
    @apps = api.get_apps.body
    logplex.parse Proc.new{|data| output_record data, @app}
    haml :index
  end

  def output_record(record, app)
    location = geolocate(record[:remote_ip])
    Pusher[app].trigger('my_event', {"lat"     => location[:latitude],
                                              "lon"     => location[:longitude],
                                              "message" => record[:path]})
  end

  def geolocate(ip)
    GeoIP.new(GEOIP_FILE).city(ip).to_hash
  end

  def logplex
    @logplexparse ||= LogplexParser.new(request.env['bouncer.token'], params['app'])
  end

end

