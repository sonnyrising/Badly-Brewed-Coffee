before "/staff/*" do
  unless session[:uname] == "staff" || session[:uname] == "manager"
    redirect "/"
  end
end

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

post "/staff/account" do
  @account = Users[params[:'account-data'].to_i]
  erb :"staff/account"
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

get "/staff/orders" do
  @shown_orders = Transactions.all

  erb :'admin/orders'
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

  redirect '/staff/managestock'
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
      redirect "/staff/managestock?error=invalid_name"
    end
  else
    product_error_message(params)
  end
end

# Return an appropriate error message if any input user input is invalid
def product_error_message(params)
  if params[:name]
    redirect "/staff/managestock?error=invalid_name"
  elsif params[:stock]
    redirect "/staff/managestock?error=invalid_stock"
  elsif params[:price]
    redirect "/staff/managestock?error=invalid_price"
  elsif params[:image]
    redirect "/staff/managestock?error=invalid_image"
  elsif params[:description]
    redirect "/staff/managestock?error=invalid_description"
  end
end

post "/staff/basketpayment" do
  erb :"staff/basketpayment"
end

post "/staff/thankyoupage" do
  transaction = Transactions.new
  transaction.load(params)
  transaction.save_changes

  Basket.orderPlaced(transaction.UserId, transaction.TransactionId)

  Users.coffeeLoyaltyPointIncrease(transaction.UserId)

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