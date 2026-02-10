require "require_all"
require "sinatra"

require_all File.join(__dir__, 'controllers')
#require_all "../controllers"
require_relative "helpers/helpers"
require_relative "db/db"
#require_all "../models"
require_all File.join(__dir__, 'models')

enable :sessions
