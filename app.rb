require 'bundler'
Bundler.require

STDOUT.sync = true

class App < Sinatra::Base

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
    haml ''
  end

end

