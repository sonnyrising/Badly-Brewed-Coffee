require 'sinatra'
require 'sqlite3'
require 'json'
require 'bcrypt'

require_relative "../models/Products"
require_relative "../models/Users"
require_relative "../models/Transactions"
require_relative "../models/Feedbacks"

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

#------------------------------ OPEN / CLOSE SESSION -------------------------------
def validate_session
  if !session[:userId]
    redirect "/login"
  else
    return
  end
end

get "/landingpage" do
  session.clear
  erb :landingpage
end

get "/" do
  session.clear
  redirect "/landingpage"
end