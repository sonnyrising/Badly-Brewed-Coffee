require 'sinatra'
require 'sqlite3'
require 'json'

require_relative "../models/ManageStock"
require_relative "../models/Users"

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

#------------------------------ OPEN / CLOSE SESSION -------------------------------

get "/landingpage" do 
  erb :landingpage
end

get "/" do
  redirect "/landingpage"
end

#------------------------------ LOGIN AND REGISTER -------------------------------

get "/login" do
  erb :loginpage
end

post "/login" do
  @uname = params.fetch("uname", "").strip
  @password = params.fetch("pword", "").strip

  @uname_error = @uname.empty? ? "Please enter a username" : nil
  @pword_error = @password.empty? ? "Please enter a password" : nil

  if @uname == "manager" && @password == "manager"
    session[:uname] = @uname
    redirect "/manager/homepage"
  elsif @uname == "staff" && @password == "staff"
    session[:uname] = @uname
    redirect "/staff/homepage"
  elsif @uname == "admin" && @password == "admin"
    session[:uname] = @uname
    redirect "/admin"
  else
    userId = Users.GetUserId(@uname)
    if !userId.nil?
      @password_validated = Users.ComparePassword(userId, @password)
      if @password_validated
        session[:userId] = userId
        session[:uname] = @uname
        redirect "/user/homepage"
      end
    end
  end
 
  erb :loginpage
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
      redirect "/user/homepage"
    end 
  end 

  erb :registerpage
end

get "/logout" do
  redirect "/login"
end

#----------------------------------- USER ROUTES ---------------------------------
get "/user/homepage" do
    erb :"user/homepage"
end

get "/user/settings" do
    erb :"user/settings"
end

get "/user/shop" do
    erb :"user/selectproducts"
end

get "/user/orders" do
    erb :"user/orderhistory"
end

get "/user/thankyoupage" do
    erb :"user/thankyoupage"
end

get "/user/contact-us" do
  erb :"user/contact_us_page"
end

post "/user/feedback-page-submit" do
  @feedback_submitted = !params.empty?

  raw_feedback = params["text_field"]
  refund_text = params["text_field"]

  @feedback_text = h(raw_feedback) unless raw_feedback.nil?
  @refund_reason = h(raw_suggestion) unless raw_suggestion.nil? 

  if @form_was_submitted
    @feedback_text_error = "Please provide us with the issue" if @feedback_text.empty?
    @refund_reason_error = "IF you picked 'No' then write \"No\" but if you picked \"Yes\" then please provide a valid reason for your refund request" if @refund_reason.empty?

    erb :"user/feedback_page_submission"
  end
end


#------------------------------------- ADMIN ROUTES ---------------------------------
$LOGIN_COUNT = 0

get "/admin" do
  @currentVisitCount = $LOGIN_COUNT
  erb :"admin/homepage"
end

get "/admin/accounts" do
  erb :"admin/accounts"
end

get "/admin/account" do
  erb :"admin/account"
end

get "/admin/feedback" do
  erb :"admin/feedback"
end

#------------------------------------- MANAGER ROUTES -------------------------------

get "/manager/homepage" do
    erb :"manager/homepage"
end

get "/manager/managestock" do
  bean = Products.where(ProductId: 1).first
  if bean
    @product_id = bean[:ProductId]
    @product_name = bean[:ProductName]
    @stock = bean[:StockQuantity]
    @price = bean[:Price]
  end

  erb :"manager/managestock"
end

post "/manager/managestock" do
  Managestock.update_product(
    params[:product_id],
    params[:product_name],
    params[:price],
    params[:stock]
  )
  redirect "/manager/managestock"
end

#------------------------------------- STAFF ROUTES ---------------------------------

get "/staff/homepage" do
    erb :"staff/homepage"
end