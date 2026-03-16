require 'sinatra'
require 'sqlite3'
require 'json'

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
      @password_validated = Users.ComparePassword(userId, @password)
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
  @products = Products.all

  erb :"user/selectproducts"
end

post "/user/shop" do
  @products = Products.all
  @basket = Basket.new

  exists = @basket.productExists(params)
  user_exists = @basket.userCheck(params)
  product_exists = @basket.productCheck(params)

  if exists.nil? || user_exists.nil? || product_exists.nil?
    @basket.addToBasket(params)
    @basket.save_changes
  else
    @basket.updateQuantity(params)
  end

  erb :"user/selectproducts"
end

get "/user/orders" do
    erb :"user/orderhistory"
end

get "/user/thankyoupage" do
    erb :"user/thankyoupage"
end

get "/user/contact_us_page" do
  erb :"user/contact_us_page"
end

get "/user/feedback_page_submission" do
  erb :"user/feedback_page_submission"
end

get "/user/basketpayment" do
  erb :"user/basketpayment"
end 

post "/user/basketpayment" do
  erb :"user/basketpayment"
end 


post "/user/feedback-page-submit" do
  @feedback_submitted = !params.empty?

  @feedback = Feedbacks.new
  @feedback.load(params)

  @feedback_text = h(@feedback.IssueContent) 
  @refund_reason = h(@feedback.RefundReason) 

  erb :"user/feedback_page_submission"
end


#------------------------------------- ADMIN ROUTES ---------------------------------

get "/admin" do
  erb :"admin/homepage"
end

get "/admin/accounts" do
  @shown_accounts = Users.map(:UserId)
  erb :"admin/accounts"
end

get "/admin/feedback" do
  erb :"admin/feedback"
end

post "/admin/accounts/filter" do
  if !params[:'search-filter'].empty?
    @shown_accounts = []
    @shown_accounts << Users.where(Username: "#{params[:'search-filter']}").get(:UserId)
    erb :"admin/accounts"
  else
    redirect "/admin/accounts"
  end
end

post "/admin/accounts/view" do
  @userId = params[:userId]
  erb :"admin/account"
end

post "/admin/accounts/edit" do
  @userId = params[:userId]
  erb :"admin/accountedit"
end

post "/admin/accounts/edit/update" do
  userId = params[:'id-data']

  if !params[:'username-data'].empty?
    Users.where(UserId: userId).update(Username: "#{params[:'username-data']}")
  end
  if !params[:'email-data'].empty?
    Users.where(UserId: userId).update(Email: "#{params[:'email-data']}")
  end
  if !params[:'loyaltypoint-data'].empty?
    Users.where(UserId: userId).update(LoyaltyPoints: params[:'loyaltypoint-data'])
  end
  #if !params[:'address-data'].empty?
  #  Users.where(UserId: userId).update(LoyaltyPoints: "#{params[:'username-data']}")
  #end
  if !params[:'inactivity-data'].empty?
    Users.where(UserId: userId).update(DaysSinceLastUse: params[:'inactivity-data'])
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/suspend" do
  @userId = params[:userId]
  if !Users.isSuspended?(@userId)
    Users.where(UserId: @userId).update(Suspended: 1)
  else
    Users.where(UserId: @userId).update(Suspended: 0)
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/delete" do
  userId = params[:userId]
  Users.where(UserId: userId).delete
  Transactions.where(UserId: userId).delete
  Feedbacks.where(UserId: userId).delete
  Basket.where(UserId: userId).delete

  redirect "/admin/accounts"
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

post "/staff/selectproducts" do
  @products = Products.all

  erb :"staff/selectproducts"
end

get "/staff/register" do 
  erb :"staff/employeeregisterpage"
end

post "/staff/staffaccountview" do
  erb :"staff/staffaccountview"
end

get "/staff/staffaccountview" do
  erb :"staff/staffaccountview"
end

post "/staff/generatelabel" do
  erb :"staff/generatelabel"
end

post "/staff/settings" do
  erb :"staff/settings"
end

get "/staff/settings" do
  erb :"staff/settings"
end

post "/staff/basketpayment" do
  erb :"staff/basketpayment"
end

post "/staff/thankyoupage" do
  erb :"staff/thankyoupage"
end

post "/staff/staffaccountview/filter" do
  if !params[:'search-filter'].empty?
    @shown_accounts = []
    @shown_accounts << Users.where(Username: "#{params[:'search-filter']}").get(:UserId)
    erb :"staff/staffaccountview"
  else
    redirect "/staff/staffaccountview"
  end
end

post "/staff/view" do
  erb :"staff/account"
end