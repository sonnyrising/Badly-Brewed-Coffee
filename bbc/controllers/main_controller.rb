require 'sinatra'
#equire 'sqlite3'
require 'json'

#DB = SQLite3::Database.new '../db/usersdatabase.db'
#DB.results_as_hash = true

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

#------------------------------ OPEN / CLOSE SESSION -------------------------------

get "/landingpage" do 
  session.clear
  erb :landingpage
end

get "/" do
  redirect "/landingpage" unless session["logged_in"]
  if @username == "manager" && @password == "manager"
    session["logged_in"] = true
    redirect "/manager"

  elsif @username == "staff" && @password == "staff"
    session["logged_in"] = true
    redirect "/staffhomepage"
  else
    session["logged_in"] = true
    redirect "/user/KennyBrewster"
    end
end

#------------------------------ LOGIN AND REGISTER -------------------------------

get "/login" do
  erb :loginpage
end

post "/login" do
    @username = params[:uname]
    @password = params[:pword]

    if @username == "manager" && @password == "manager"
      session["logged_in"] = true
      redirect "/manager"

    elsif @username == "staff" && @password == "staff"
      session["logged_in"] = true
      redirect "/staffhomepage"
    else
      session["logged_in"] = true
      redirect "/user/KennyBrewster"
    end
end

get "/register" do
  erb :registerpage
end

post "/register" do
  @form_was_submitted = !params.empty?

  @uname = params.fetch("uname","").strip
  @email = params.fetch("email","").strip

  if @form_was_submitted
    @uname_error = "Please enter a username" if @uname.empty?
    @email_error = "Please enter a valid email" unless str_email_address?(@email)

    unless @uname_error.nil? && @email_error.nil? 
      @submission_error = "Please correct the errors below"
    end 

    if @submission_error.nil?
      redirect "/user/#{@uname}"
    end 
  end 

  #@username = params[:uname]
  #@password = params[:pword]

  #if params[:pword] == params[:confirmpword]
   # erb :userhomepage
  #end
end

get "/logout" do
  redirect "/landingpage"
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