# frozen_string_literal: true

require 'sinatra'
require 'sqlite3'
require 'json'
require 'bcrypt'

require_relative '../models/Products'
require_relative '../models/Users'
require_relative '../models/Transactions'
require_relative '../models/Feedbacks'

set :public_folder, File.expand_path('../public', __dir__)
set :views, File.expand_path('../views', __dir__)

before '/manager/*' do
  redirect '/login' unless ["manager", "admin"].include?(Users[session[:userId]].AccountType)
end

get '/manager/homepage' do
  erb :"manager/homepage"
end

get '/manager/adjustloyalty' do
  @users = Users.where(Suspended: 0)
  erb :"manager/adjustloyalty"
end

get '/manager/viewfeedback' do
  options = params['filter']

  @shown_feedback = if options == 'refund'
                      Feedbacks.where(RefundRequest: 1).all
                    else
                      Feedbacks.all
                    end

  erb :"manager/viewfeedback"
end

post '/manager/updatediscount' do
  user_id = params[:user_id]
  raw_value = params[:discount]

  ## Regex checs the input is a number less than 100
  if raw_value.nil? || raw_value.strip.empty? || raw_value !~ /\A\d+\z/
    @alert_message = 'Please enter a valid discount percentage (0-100).'
    @users = Users.where(Suspended: 0)
    halt erb :"manager/adjustloyalty"
  end

  discount = raw_value.to_i

  if discount > 100
    @alert_message = 'Please enter a valid discount percentage (0-100).'
    @users = Users.where(Suspended: 0)
    halt erb :"manager/adjustloyalty"
  end

  Users.where(UserId: user_id).update(LoyaltyDiscount: discount)
  redirect '/manager/adjustloyalty'
end
