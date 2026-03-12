require 'sinatra'
require 'sqlite3'
require 'json'
require 'digest'

require_relative "../models/Products"
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
  @matching_error = nil

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
      @password_hash = Digest::SHA256.hexdigest(@password)
      @password_validated = Users.ComparePassword(userId, @password_hash)
      if @password_validated
        session[:userId] = userId
        session[:uname] = @uname
        redirect "/user/homepage"
      else
        @matching_error = "Username or password are incorrect"
      end
    else  
      @matching_error = "Username or password are incorrect"
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

  @user = Users.new
  @user.load(params)

  @uname = params.fetch("uname","").strip
  @email = params.fetch("email","").strip
  @pword = params.fetch("pword","").strip
  @confirmpword = params.fetch("confirmpword","").strip
  @password_hash = Digest::SHA256.hexdigest(@password)

  if @form_was_submitted
    @uname_error = "Please enter a username" if @uname.empty?
    @password_error = "Please enter a password" if @pword.empty?
    @confirmpassword_error = "Please enter your password again" if @confirmpword.empty?
    @email_error = "Please enter a valid email" unless str_email_address?(@email)
    @pword_match_error = "Passwords dont match" if @pword != @confirmpword
    @invalid_pword = "Password must contain contain lower and upper case letters, a digit, a special character and be at least 8 characters long" if !@pword.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[[:^alnum:]]).{8,}$/)
    @taken_username = "That username is already taken, try a different one" if @user.compareUsername(@uname)

    unless @uname_error.nil? && @email_error.nil? && @password_error.nil? && @confirmpassword_error.nil? && @pword_match_error.nil? && @invalid_pword.nil? && @taken_username.nil?
      @submission_error = "Please correct the errors below"
    end 

    if @submission_error.nil?
      session[:uname] = @uname
      @user.save_changes
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

  raw_issue = params["issue"]
  refund_text = params["reason"]

  @feedback_text = h(raw_issue) unless raw_issue.nil?
  @refund_reason = h(refund_text) unless refund_text.nil? 

  if @feedback_submitted
    @feedback_text_error = "Please provide us with the issue" if @feedback_text.nil?
    @refund_reason_error = "IF you picked 'No' then write \"No\" but if you picked \"Yes\" then please provide a valid reason for your refund request" if @refund_reason.nil?

    erb :"user/feedback_page_submission"
  end
end


#------------------------------------- ADMIN ROUTES ---------------------------------

get "/admin" do
  erb :"admin/homepage"
end

get "/admin/accounts" do
  erb :"admin/accounts"
end

get "/admin/feedback" do
  erb :"admin/feedback"
end

post "/admin/accounts/view" do
  erb :"admin/account"
end

post "/admin/accounts/edit" do
  erb :"admin/accountinfo"
end

post "/admin/accounts/delete" do
  redirect "/admin"
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

post "/manager/updatestock" do
  Products.update_product(
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

get "/staff/register" do 
  erb :"staff/employeeregisterpage"
end

get "/staffaccountview" do
  erb :"staff/staffaccountview"
end