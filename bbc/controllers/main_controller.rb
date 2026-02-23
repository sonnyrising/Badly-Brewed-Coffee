require 'sinatra'
require 'sqlite3'
require 'json'

#DB = SQLite3::Database.new '../db/usersdatabase.db'
#DB.results_as_hash = true

get "/" do
  redirect "/public"
end

get "/login" do
  erb :loginpage
end

post "/login" do
    @username = params[:uname]
    @password = params[:pword]

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


