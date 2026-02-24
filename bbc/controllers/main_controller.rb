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


#------------------------------ LOGIN AND REGISTER -------------------------------

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
      redirect "/user/KennyBrewster"
    end
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

#----------------------------------- USER ROUTES ---------------------------------

get "/user/:name" do
    @name = params[:name]
    erb :userhomepage
end

get "/user/settings" do
  erb :settingspage
end

get "/user/selectproducts" do
  erb :selectproducts
end

get "/user/orderhistory" do
  erb :orderhistory
end

get "/user/thankyoupage" do
  erb :thankyoupage
end

#------------------------------------- ADMIN ROUTES ---------------------------------

get "/admin" do
    erb :adminhomepage
end

get "/admin/login" do
    'Admin login!'
end

#------------------------------------- MANAGER ROUTES -------------------------------

get "/manager" do
    erb :managerhomepage
end

#------------------------------------- STAFF ROUTES ---------------------------------

get "/staff" do
    erb :staffhomepage
end