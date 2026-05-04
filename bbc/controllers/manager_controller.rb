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

before "/manager/*" do
  if session[:uname] != "manager"
    redirect "/login"
  end
end

get "/manager/homepage" do
  erb :"manager/homepage"
end

get "/manager/salesmetrics" do
  erb :"manager/salesmetrics"
end

get "/manager/adjustloyalty" do
  @users = Users.where(Suspended: 0)
  erb :"manager/adjustloyalty"
end

get "/manager/viewfeedback" do
  options = params["filter"]
  
  if options == "refund"
    @shown_feedback = Feedbacks.where(RefundRequest: 1).all
  else
    @shown_feedback = Feedbacks.all
  end
  
  puts "=== DEBUG: I found #{@shown_feedback.count} records in the DB! ==="
  
  puts "=== DEBUG: Data: #{@shown_feedback.inspect} ==="

  erb :"manager/viewfeedback"
end

post "/manager/updatediscount" do
  user_id = params[:user_id]
  discount = params[:discount]
  if discount.nil?
    @alert_message = "Please enter a valid discount percentage (0-100)."
    @users = Users.where(Suspended: 0)
    return erb :"manager/adjustloyalty"
  else
    discount = discount.to_i
  end

  if discount.negative? || discount > 100
    @alert_message = "Please enter a valid discount percentage (0-100)."
    @users = Users.where(Suspended: 0)
    return erb :"manager/adjustloyalty"
  else
    Users.where(UserId: user_id).update(LoyaltyDiscount: discount)
  end

  redirect "/manager/adjustloyalty"
end


