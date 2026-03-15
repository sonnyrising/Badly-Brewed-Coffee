require "require_all"
require "sinatra"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_all "models"

set :views, File.join(__dir__, "views")

enable :sessions
set :session_secret, "bbc_super_secret_key_to_make_it able_to_access_session_details_that_needs_to_be_64_characters_long"