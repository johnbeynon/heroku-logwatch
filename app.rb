require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  haml '\'ello world'
end

