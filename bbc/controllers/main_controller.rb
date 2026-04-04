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

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def validate_session
  if !session[:userId]
    redirect "/login"
  else
    return
  end
end

#------------------------------ OPEN / CLOSE SESSION -------------------------------

get "/landingpage" do
  session.clear
  erb :landingpage
end

get "/" do
  session.clear
  redirect "/landingpage"
end

#------------------------------ LOGIN AND REGISTER -------------------------------

get "/login" do
  session.clear
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
    session[:userId] = 1
    redirect "/admin"
  else
    userId = Users.GetUserId(@uname)
    if !userId.nil?
      @password_validated = Users.ComparePassword(userId, @password)
      if @password_validated
        session[:userId] = userId
        session[:uname] = @uname
        redirect "/user/homepage" unless !session[:userId]
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

post "/user/homepage" do
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

post "/user/shop/add" do
  @products = Products.all
  Basket.add(params)

  erb :"user/selectproducts"
end

post "/user/shop/subtract" do
  @products = Products.all
  Basket.subtract(params)

  erb :"user/selectproducts" 
end

post "/user/shop/delete" do 
  @products = Products.all
  Basket.RemoveItem(params)

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

post "/thankyoupage" do
  transaction = Transactions.new
  transaction.load(params)

  transaction.save_changes

  Basket.orderPlaced(transaction.UserId, transaction.TransactionId)

  erb :"user/thankyoupage"
end

post "/user/feedback-page-submit" do
  @feedback_submitted = !params.empty?

  @feedback = Feedbacks.new
  @feedback.load(params)

  if @feedback.save_changes 
    @feedback_text = h(@feedback.IssueContent)
    @refund_reason = h(@feedback.RefundReason)
    erb :"user/feedback_page_submission"
  else
    @error = "Something went wrong. Please try again!"
    erb :"user/contact_us_page"
  end
end


#------------------------------------- ADMIN ROUTES ---------------------------------

get "/admin" do
  validate_session
  erb :"admin/homepage"
end

get "/admin/accounts" do
  validate_session
  @shown_accounts = Users.map(:UserId)
  erb :"admin/accounts"
end

get "/admin/views" do
  validate_session
  erb :'admin/viewselection'
end

post "/admin/views/manager" do
  validate_session
  erb :'manager/homepage'
end

post "/admin/views/barista" do
  validate_session
  erb :'staff/homepage'
end

post "/admin/views/user" do
  validate_session
  erb :'user/homepage'
end

get "/admin/feedback" do
  validate_session
  #@shown_feedback = Feedbacks.map(:FeedbackId)

  if params["filter"] == "Yes"
    @shown_feedback = Feedbacks.where(RefundRequest: true).all
  else
    @shown_feedback = Feedbacks.where(RefundRequest: false).all
  end
  
  erb :"admin/feedback"
end

post "/admin/feedback/filter" do
  validate_session
  if !params[:'search-filter'].empty?
    @shown_feedback = []
    @shown_feedback << Feedbacks.where(FeedbackId: params[:'search-filter'].to_i).get(:FeedbackId)
    erb :"admin/feedback"
  else
    redirect "/admin/feedback"
  end
end

post "/admin/feedback/delete" do
  validate_session
  feedbackId = params[:feedbackId]
  Feedbacks.where(FeedbackId: feedbackId).delete

  redirect "/admin/feedback"
end

post "/admin/accounts/create" do
  validate_session
  erb :"admin/accountcreation"
end

post "/admin/accounts/create/submit" do
  validate_session
  @userId = 1
  @password = BCrypt::Password.create("password")
  puts params[:'type-data']
  if(params[:'type-data'] == "Staff")
    puts "Creating a staff account!"
    @userId = validate_staff_id(@userId)
    Staff.insert(StaffId: @userId, StaffUsername: "#{params[:'username-data']}", StaffEmail: "#{params[:'email-data']}", StaffPasswordHash: @password, EmployeeLevel: 'Barista', EmploymentStatus: 1)
  else
    puts "Creating a user account!"
    @userId = validate_user_id(@userId)
    Users.insert(UserId: @userId, Username: "#{params[:'username-data']}", PassHash: @password, Email: "#{params[:'email-data']}", LoyaltyPoints: 0, DaysSinceLastUse: 0, Suspended: 0)
  end
  redirect "/admin/accounts"
end

def validate_staff_id(userId)
  if Staff.where(StaffId: userId).empty?
    return userId
  else
    validate_staff_id(userId += 1)
  end
end

def validate_user_id(userId)
  if Users.where(UserId: userId).empty?
    return userId
  else
    validate_user_id(userId + 1)
  end
end

post "/admin/accounts/filter" do
  validate_session
  if !params[:'search-filter'].empty?
    @shown_accounts = []
    @shown_accounts << Users.where(Username: "#{params[:'search-filter']}").get(:UserId)
    erb :"admin/accounts"
  else
    redirect "/admin/accounts"
  end
end

post "/admin/accounts/view" do
  validate_session
  @userId = params[:userId]
  erb :"admin/account"
end

post "/admin/accounts/edit" do
  validate_session
  @userId = params[:userId]
  erb :"admin/accountedit"
end

post "/admin/accounts/edit/update" do
  validate_session
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

post "/admin/accounts/edit/recover" do
  validate_session
  userId = params[:'id-data']
  @password = BCrypt::Password.create("password")

  Users.where(UserId: userId).update(PassHash: @password)

  redirect "/admin/accounts"
end

post "/admin/accounts/suspend" do
  validate_session
  @userId = params[:userId]
  if !Users.isSuspended?(@userId)
    Users.where(UserId: @userId).update(Suspended: 1)
  else
    Users.where(UserId: @userId).update(Suspended: 0)
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/delete" do
  validate_session
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
  @products = Products.all

  @alert_message = case params[:error]
                   when "invalid_name"  then "Please enter a valid product name."
                   when "invalid_stock" then "Please enter a valid stock quantity."
                   when "invalid_price" then "Please enter a valid price."
                   when "invalid_image" then "Please enter a valid image URL."
                   when "invalid_description" then "Please enter a valid description."
                   end


  erb :"manager/managestock"
end



#  Updates the product table based on user inputs
post '/manager/updatestock' do
  product = Products[params['product_id']]
  # Sanitise the input before updating the database
  name = sanitise_string(params['product_name'])
  stock = sanitise_int(params['product_stock'])
  price = sanitise_price(params['product_price'])
  image = sanitise_string(params['product_image'])
  description = sanitise_string(params['product_description'])

  # Check all inputs are valid
  if name && stock && price && image && description
    if product
      product.update(
        ProductName: params['product_name'],
        StockQuantity: params['product_stock'],
        Price: params['product_price'],
        ProductImage: params['product_image'],
        ProductDescription: params['product_description']
      )
    end
  else
    # Display an error message if any input is invalid
    if !name
      redirect "/manager/managestock?error=invalid_name"
    elsif !stock
      redirect "/manager/managestock?error=invalid_stock"
    elsif !price
      redirect "/manager/managestock?error=invalid_price"
    elsif !image
      redirect "/manager/managestock?error=invalid_image"
    elsif !description
      redirect "/manager/managestock?error=invalid_description"
    end

    puts session[:alert_message]
  end

  redirect '/manager/managestock'
end

post "/manager/deleteproduct" do
  product_id = params[:product_id]
  Products.where(ProductId: product_id).delete
  redirect "/manager/managestock"
end

get "/manager/addproduct" do
  erb :"manager/addproduct"
end

# post "/manager/addproduct" do
#   highest_id = Products.max(:ProductId)
#   @products = Products.all
#   Products.insert(
#     ProductId: highest_id + 1,
#     ProductName: params[:product_name],
#     StockQuantity: params[:product_stock],
#     Price: params[:product_price],
#     ProductImage: params[:product_image],
#     ProductDescription: params[:product_description]
#   )
#   redirect "/manager/managestock"
# end

get "/manager/beanssold" do
  erb :"manager/beanssold"
end

get "/manager/coffeessold" do
  erb :"manager/coffeessold"
end

get "/manager/freecoffeesredeemed" do
  erb :"manager/freecoffeesredeemed"
end

get "/manager/topcustomers" do
  erb :"manager/topcustomers"
end

get "/manager/topproducts" do
  erb :"manager/topproducts"
end

get "/manager/orders" do
  @orders = Transactions.all
  erb :"manager/orders"
end


get "/manager/refunds" do
  @refunds = Transactions.where(refundRequested: true)

  if params[:message] == "accept"
    @alert_message = "Refund has been accepted."
    Transactions.where(TransactionId: params[:refund_id]).update(refundRequested: false)
  elsif params[:message] == "decline"
    @alert_message = "Refund has been declined."
    Transactions.where(TransactionId: params[:refund_id]).update(refundRequested: false)
  end

  erb :"manager/refunds"
end

get "/manager/refunddetails" do
  transaction_id = params[:transaction_id]
  user_id = Transactions.where(TransactionId: transaction_id).get(:UserId)
  total_cost = Transactions.where(TransactionId: transaction_id).get(:TotalCost)
  transaction_date = format_date(Transactions.where(TransactionId: transaction_id).get(:TransactionDate))
  status = Transactions.where(TransactionId: transaction_id).get(:Status)
  refund_reason = Feedbacks.where(TransactionId: transaction_id).get(:RefundReason)
  @refund_info = {
    transaction_id: transaction_id,
    user_id: user_id,
    total_cost: total_cost,
    transaction_date: transaction_date,
    status: status,
    refund_reason: refund_reason
  }

  erb :"manager/refunddetails"
end

post "/manager/orders/updatestatus" do
  transaction_id = params[:transaction_id]
  new_status = params[:status]

  Transactions.where(TransactionId: transaction_id).update(Status: new_status)

  redirect "/manager/orders"
end

# Helper Methods to sanitise the database entries
def sanitise_price(input)
  # Ensure the input is a number greater than 0
  if ((input.to_f.to_s == input) || (input.to_i.to_s == input)) && (input.to_f > 0)
    return '%.2f' % input.to_f
  else
    return false
  end
end

def sanitise_int(input)
  # Ensure the input is an integer greater than 0
  if (input.to_i.to_s == input) && (input.to_i > 0)
    return input.to_i
  else
    return false
  end
end

def sanitise_string(input)
  # Check for any SQL injection attempts
  if (input.include?("'") || input.include?('"') || input.include?(";") || input.include?("="))
    return false
  else
    return input
  end
end

# Helper method to format an integer as a date
def format_date(date_int)
  # Converts to a string and pads with zeros to ensure 8 characters
  date_str = date_int.to_s.rjust(8, '0')
  # Adds a slash to format as dd/mm/yyyy
  "#{date_str[0..1]}/#{date_str[2..3]}/#{date_str[4..7]}"
end
#------------------------------------- STAFF ROUTES ---------------------------------

get "/staff/homepage" do
    erb :"staff/homepage"
end

post "/staff/selectproducts" do
  @products = Products.all

  erb :"staff/selectproducts"
end

get "/staff/selectproducts" do
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

post "/staff/orders" do
  @orders = Transactions.all
  erb :"staff/orders"
end

get "/staff/managestock" do
  @products = Products.all

  @alert_message = case params[:error]
                   when "invalid_name"  then "Please enter a valid product name."
                   when "invalid_stock" then "Please enter a valid stock quantity."
                   when "invalid_price" then "Please enter a valid price."
                   when "invalid_image" then "Please enter a valid image URL."
                   when "invalid_description" then "Please enter a valid description."
                   end


  erb :"staff/managestock"
end

post "/staff/managestock" do
  @products = Products.all

  @alert_message = case params[:error]
                   when "invalid_name"  then "Please enter a valid product name."
                   when "invalid_stock" then "Please enter a valid stock quantity."
                   when "invalid_price" then "Please enter a valid price."
                   when "invalid_image" then "Please enter a valid image URL."
                   when "invalid_description" then "Please enter a valid description."
                   end


  erb :"staff/managestock"
end



#  Updates the product table based on user inputs
post '/staff/updatestock' do
  product = Products[params['product_id']]
  # Sanitise the input before updating the database
  name = sanitise_string(params['product_name'])
  stock = sanitise_int(params['product_stock'])
  price = sanitise_price(params['product_price'])
  image = sanitise_string(params['product_image'])
  description = sanitise_string(params['product_description'])

  # Check all inputs are valid
  if name && stock && price && image && description
    if product
      product.update(
        ProductName: params['product_name'],
        StockQuantity: params['product_stock'],
        Price: params['product_price'],
        ProductImage: params['product_image'],
        ProductDescription: params['product_description']
      )
    end
  else
    # Display an error message if any input is invalid
    if !name
      redirect "/staff/managestock?error=invalid_name"
    elsif !stock
      redirect "/staff/managestock?error=invalid_stock"
    elsif !price
      redirect "/staff/managestock?error=invalid_price"
    elsif !image
      redirect "/staff/managestock?error=invalid_image"
    elsif !description
      redirect "/staff/managestock?error=invalid_description"
    end

    puts session[:alert_message]
  end

  redirect '/staff/managestock'
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
    redirect "/staff/staffaccountview"
  else
    redirect "/staff/staffaccountview"
  end
end

post "/staff/view" do
  erb :"staff/account"
end

post "/staff/shop/add" do
  @products = Products.all
  Basket.add(params)

  redirect "/staff/selectproducts"
end

post "/staff/shop/subtract" do
  @products = Products.all
  Basket.subtract(params)

  redirect "/staff/selectproducts"
end

post "/staff/shop/delete" do 
  @products = Products.all
  Basket.RemoveItem(params)

  redirect "/staff/selectproducts"
end