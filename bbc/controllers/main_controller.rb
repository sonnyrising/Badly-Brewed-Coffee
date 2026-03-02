require 'sinatra'
#equire 'sqlite3'
require 'json'

#DB = SQLite3::Database.new '../db/usersdatabase.db'
#DB.results_as_hash = true

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

#------------------------------ OPEN / CLOSE SESSION -------------------------------

get "/landingpage" do 
  erb :landingpage
end

get "/" do
  $LOGIN_COUNT += 1
  redirect "/landingpage"
end

#------------------------------ LOGIN AND REGISTER -------------------------------

get "/login" do
  erb :loginpage
end

post "/login" do
  @uname = params[:uname]
  @password = params[:pword]

  if @uname == "manager" && @password == "manager"
    session[:uname] = @uname
    redirect "/managerhomepage"

  elsif @uname == "staff" && @password == "staff"
    session[:uname] = @uname
    redirect "/staffhomepage"
  else
    session[:uname] = params[:uname]
    redirect "/userhomepage"
  end
end

get "/forgotpassword" do
    erb :forgotpassword
end

get "/register" do
    erb :registerpage
end

post "/register" do
  @form_was_submitted = !params.empty?

  @uname = params.fetch("uname","").strip
  @email = params.fetch("email","").strip
  @pword = params.fetch("pword","").strip
  @confirmpword = params.fetch("confirmpword","").strip

  if @form_was_submitted
    @uname_error = "Please enter a username" if @uname.empty?
    @password_error = "Please enter a password" if @pword.empty?
    @confirmpassword_error = "Please enter your password again" if @confirmpword.empty?
    @email_error = "Please enter a valid email" unless str_email_address?(@email)
    @pword_match_error = "Passwords dont match" if @pword != @confirmpword
    @invalid_pword = "Password must contain contain lower and upper case letters, a digit, a special character and be at least 8 characters long" if !@pword.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[[:^alnum:]]).{8,}$/)

    unless @uname_error.nil? && @email_error.nil? && @password_error.nil? && @confirmpassword_error.nil? && @pword_match_error.nil? && @invalid_pword.nil?
      @submission_error = "Please correct the errors below"
    end 

    if @submission_error.nil?
      session[:uname] = @uname
      redirect "/userhomepage"
    end 
  end 

  erb :registerpage
end

get "/logout" do
  redirect "/landingpage"
end

#----------------------------------- USER ROUTES ---------------------------------
get "/userhomepage" do
    erb :userhomepage
end

get "/user/settings" do
    erb :settings
end

get "/user/shop" do
    erb :selectproducts
end

get "/user/orders" do
    erb :orderhistory
end

get "/user/thankyoupage" do
    erb :thankyoupage
end

get "/user/feedback-page" do
  erb :feedbackpage
end

post "/user/feedback-page-submit" do
  raw_feedback = params["text_field"]
  raw_suggestion = params["text_field"]

  @feedback_text = h(raw_feedback) unless raw_feedback.nil?
  @suggestion_feedback_text = h(raw_suggestion) unless raw_suggestion.nil? 

  erb :feedback_page_submission
end


#------------------------------------- ADMIN ROUTES ---------------------------------
$LOGIN_COUNT = 0

get "/admin" do
  @currentVisitCount = $LOGIN_COUNT
  erb :adminhomepage
end

get "/admin/login" do
    'Admin login!'
end

#------------------------------------- MANAGER ROUTES -------------------------------

get "/managerhomepage" do
    erb :managerhomepage
end

#------------------------------------- STAFF ROUTES ---------------------------------

get "/staffhomepage" do
    erb :staffhomepage
end