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
  t_id = params[:transaction_id]

  @refund_info = {
    transaction_id: t_id,
    user_id: Transactions.where(TransactionId: t_id).get(:UserId),
    total_cost: Transactions.where(TransactionId: t_id).get(:TotalCost),
    transaction_date: format_date(Transactions.where(TransactionId: t_id).get(:TransactionDate)),
    status: Transactions.where(TransactionId: t_id).get(:Status),
    refund_reason: Feedbacks.where(TransactionId: t_id).get(:RefundReason)
  }

  erb :"manager/refunddetails"
end

post "/manager/orders/updatestatus" do
  transaction_id = params[:transaction_id]
  new_status = params[:status]

  Transactions.where(TransactionId: transaction_id).update(Status: new_status)

  redirect "/manager/orders"
end


