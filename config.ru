require 'heroku/bouncer'
require './app'

use Heroku::Bouncer
run App
