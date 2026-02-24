require 'sinatra'
require 'sqlite3'
require 'json'

require_relative 'manager_controller'

#DB = SQLite3::Database.new '../db/usersdatabase.db'
#DB.results_as_hash = true

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

get "/" do
  erb :landingpage
end

get "/login" do
  erb :loginpage
end

post "/login" do
    @username = params[:uname]
    @password = params[:pword]

    if @username == "manager" && @password == "manager"
      redirect "/manager"

    elsif @username == "staff" && @password == "staff"
      redirect "/staffhomepage"
    else
      erb :userhomepage
    end
end

get "/userhomepage" do
  erb :userhomepage
end

get "/register" do
  erb :registerpage
end

post "/register" do
  @username = params[:uname]
  @password = params[:pword]

  if params[:pword] == params[:confirmpword]
    erb :userhomepage
  end
end

post "/settings" do
  erb :settings
end

post "/selectproducts" do
  erb :selectproducts
end

post "/orderhistory" do
  erb :orderhistory
end
