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
    username = params[:uname]
    password = params[:pword]

    #user = DB.get_first_row("SELECT * FROM Users WHERE username = ?", [username])

    #puts "First result: #{user}"
end
