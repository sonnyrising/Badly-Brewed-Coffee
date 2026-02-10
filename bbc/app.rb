require "require_all"
require "sinatra"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_all "models"

set :views, File.join(__dir__, "views")

enable :sessions