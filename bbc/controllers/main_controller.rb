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

#------------------------------ OPEN / CLOSE SESSION -------------------------------
get '/landingpage' do
  session.clear
  erb :landingpage
end

get '/' do
  session.clear
  redirect '/landingpage'
end

#------------------------------ Manager and Staff Shared Functionality -------------------------------
before '/*' do
  @has_access = true if %w[staff manager admin].include?(session[:uname])
end

before '/managestock' do
  redirect '/' unless @has_access
end

before '/orders' do
  redirect '/' unless @has_access
end

before '/refunds' do
  redirect '/' unless @has_access
end

before '/refunddetails' do
  redirect '/' unless @has_access
end

before '/addproduct' do
  redirect '/' unless @has_access
end

before '/deleteproduct' do
  redirect '/login' unless @has_access
end

before '/updatestock' do
  redirect '/login' unless @has_access
end

get '/orders' do
  @orders = Transactions.all
  erb :orders
end

get '/refunds' do
  if params[:message] == 'accept'
    @alert_message = 'Refund has been accepted.'
    Transactions.where(TransactionId: params[:refund_id]).update(refundRequested: false)
    Transactions.where(TransactionId: params[:refund_id]).update(Status: 'Refunded')
    Transactions.where(TransactionId: params[:refund_id]).update(Refunded: true)
  elsif params[:message] == 'decline'
    @alert_message = 'Refund has been declined.'
    Transactions.where(TransactionId: params[:refund_id]).update(refundRequested: false)
  end

  @refunds = Transactions.where(refundRequested: true) # ← now reflects the updated DB state

  erb :refunds
end

get '/refunddetails' do
  t_id = params[:transaction_id]

  @refund_info = {
    transaction_id: t_id,
    user_id: Transactions.where(TransactionId: t_id).get(:UserId),
    total_cost: Transactions.where(TransactionId: t_id).get(:TotalCost),
    transaction_date: format_date(Transactions.where(TransactionId: t_id).get(:TransactionDate)),
    status: Transactions.where(TransactionId: t_id).get(:Status),
    refund_reason: Feedbacks.where(TransactionId: t_id).get(:RefundReason)
  }

  erb :refunddetails
end

post '/updatestatus' do
  transaction_id = params[:transaction_id]
  new_status = params[:status]

  Transactions.where(TransactionId: transaction_id).update(Status: new_status)

  redirect '/orders'
end

get '/managestock' do
  @products = Products.all

  @alert_message = case params[:error]
                   when 'invalid_name'  then 'Please enter a valid product name.'
                   when 'invalid_stock' then 'Please enter a valid stock quantity.'
                   when 'invalid_price' then 'Please enter a valid price.'
                   when 'invalid_image' then 'Please enter a valid image URL.'
                   when 'invalid_description' then 'Please enter a valid description.'
                   when 'invalid_origin' then 'Please enter a valid origin.'
                   when 'invalid_roast' then 'Please enter a valid roast.'
                   when 'invalid_type' then 'Please enter a valid product type (Bean or Coffee).'
                   end
  erb :managestock
end

# Updates the product table based on user inputs
post '/updatestock' do
  values_hash = {
    product: Products[params['product_id']],
    # Sanitise the input before updating the database
    name: sanitise_string(params['product_name']),
    stock: sanitise_int(params['product_stock']),
    price: sanitise_price(params['product_price']),
    image: sanitise_string(params['product_image']),
    description: sanitise_string(params['product_description']),
    origin: sanitise_string(params['product_origin']),
    roast: sanitise_string(params['product_roast']),
    type: check_type(params['product_type'])
  }
  update_product_values(values_hash)

  redirect 'managestock'
end

get '/addproduct' do
  erb :addproduct
end

post '/addproduct' do
  name        = sanitise_string(params['product_name'])
  stock       = sanitise_int(params['product_stock'])
  price       = sanitise_price(params['product_price'])
  image       = sanitise_string(params['product_image'])
  description = sanitise_string(params['product_description'])
  origin      = sanitise_string(params['product_origin'])
  roast       = sanitise_string(params['product_roast'])
  type        = check_type(params['product_type'])

  # Name stock and price are required
  if name == false
    redirect '/managestock?error=invalid_name'
  elsif stock == false
    redirect '/managestock?error=invalid_stock'
  elsif price == false
    redirect '/managestock?error=invalid_price'
  elsif image == false
    redirect '/managestock?error=invalid_image'
  elsif description == false
    redirect '/managestock?error=invalid_description'
  elsif origin == false
    redirect '/managestock?error=invalid_origin'
  elsif roast == false
    redirect '/managestock?error=invalid_roast'
  elsif type == false
    redirect '/managestock?error=invalid_type'
  else
    highest_id = Products.max(:ProductId)
    Products.insert(
      ProductId: highest_id + 1,
      ProductName: name,
      StockQuantity: stock,
      Price: price,
      ProductImage: image,
      ProductDescription: description,
      Origin: origin,
      Roast: roast,
      Bean: (type == 'Bean')
    )
    redirect '/managestock'
  end
end

post '/deleteproduct' do
  product_id = params[:product_id]

  # Use a regex to check if the product_id is a valid integer
  if product_id.nil? || product_id.to_s !~ /\A\d+\z/ || Products[product_id.to_i].nil?
    puts "Error: Invalid product ID: #{product_id}"
  else
    Products.where(ProductId: product_id.to_i).delete
  end

  redirect '/managestock'
end
