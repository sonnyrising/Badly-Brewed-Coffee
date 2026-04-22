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

before "/manager/*" do
  if session[:uname] != "manager"
    redirect "/login"
  end
end

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

# Updates the product table based on user inputs
post '/manager/updatestock' do
  values_hash = {
    product: Products[params['product_id']],
    # Sanitise the input before updating the database
    name: sanitise_string(params['product_name']),
    stock: sanitise_int(params['product_stock']),
    price: sanitise_price(params['product_price']),
    image: sanitise_string(params['product_image']),
    description: sanitise_string(params['product_description'])
  }
  update_product_values(values_hash)

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

post "/manager/addproduct" do
  highest_id = Products.max(:ProductId)
  @products = Products.all
  Products.insert(
    ProductId: highest_id + 1,
    ProductName: params[:product_name],
    StockQuantity: params[:product_stock],
    Price: params[:product_price],
    ProductImage: params[:product_image],
    ProductDescription: params[:product_description]
  )
  redirect "/manager/managestock"
end

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
  @refund_info = {
    transaction_id: params[:transaction_id],
    user_id: Transactions.where(TransactionId: transaction_id).get(:UserId),
    total_cost: Transactions.where(TransactionId: transaction_id).get(:TotalCost),
    transaction_date: format_date(Transactions.where(TransactionId: transaction_id).get(:TransactionDate)),
    status: Transactions.where(TransactionId: transaction_id).get(:Status),
    refund_reason: Feedbacks.where(TransactionId: transaction_id).get(:RefundReason)
  }

  erb :"manager/refunddetails"
end

post "/manager/orders/updatestatus" do
  transaction_id = params[:transaction_id]
  new_status = params[:status]

  Transactions.where(TransactionId: transaction_id).update(Status: new_status)

  redirect "/manager/orders"
end

# Helper method to update the values of the product table
def update_product_values(params)
  # Check all inputs are valid
  if params[:name] && params[:stock] && params[:price] && params[:image] && params[:description]
    # Update the product
    if params[:product]
      params[:product].update(
        ProductName: params[:name],
        StockQuantity: params[:stock],
        Price: params[:price],
        ProductImage: params[:image],
        ProductDescription: params[:description]
      )
    else
      redirect "/manager/managestock?error=invalid_name"
    end
  else
    product_error_message(params)
  end
end

# Return an appropriate error message if any input user input is invalid
def product_error_message(params)
  if params[:name]
    redirect "/manager/managestock?error=invalid_name"
  elsif params[:stock]
    redirect "/manager/managestock?error=invalid_stock"
  elsif params[:price]
    redirect "/manager/managestock?error=invalid_price"
  elsif params[:image]
    redirect "/manager/managestock?error=invalid_image"
  elsif params[:description]
    redirect "/manager/managestock?error=invalid_description"
  end
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

