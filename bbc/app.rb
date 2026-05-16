# frozen_string_literal: true

require 'require_all'
require 'sinatra'

enable :sessions
set :session_secret,
    'bbc_super_secret_key_to_make_it able_to_access_session_details_that_needs_to_be_64_characters_long'
set :views, File.join(__dir__, 'views')

require_relative 'db/db'
require_all 'models'

require_relative 'helpers/helpers'

require_all 'controllers'