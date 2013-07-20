require 'bundler'
Bundler.require

STDOUT.sync = true

class App < Sinatra::Base
  set :raise_errors, false
  set :show_exceptions, false

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  helpers do
    # Heroku API
    def api
      halt(401) unless request.env['bouncer.token']
      Heroku::API.new(:api_key => request.env['bouncer.token'])
    end
  end

  get '/' do
    @apps = api.get_apps.body.sort{|x,y| x["name"] <=> y["name"]}
  end

  #error Heroku::API::Errors::Unauthorized do
  #  session[:return_to] = request.url
  #  redirect to('/auth/heroku')
  #end

end

