# frozen_string_literal: true

before '/staff/*' do
  redirect '/login' unless ["staff", "manager", "admin"].include?(Users[session[:userId]].AccountType)
end

get '/staff/homepage' do
  @shown_orders = Transactions.all

  erb :"staff/homepage"
end

post '/staff/selectproducts' do
  @products = Products.all

  erb :"staff/selectproducts"
end

post '/staff/shop' do
  @products = Products.all
  @basket = Basket.new

  exists = @basket.productExists(params)
  user_exists = @basket.userCheck(params)
  product_exists = @basket.productCheck(params)
  item_bought = @basket.bought(params)

  if !item_bought.nil?
    latest_product = @basket.checkLatest(params)
    if latest_product.nil?
      if Products.coffeeOrBeans(params) == true
        @basket.addBeanToBasket(params)
      else
        @basket.addCoffeeToBasket(params)
      end
      @basket.save_changes
    else
      @basket.updateQuantity(params)
    end
  elsif exists.nil? || user_exists.nil? || product_exists.nil?
    if Products.coffeeOrBeans(params) == true
      @basket.addBeanToBasket(params)
    else
      @basket.addCoffeeToBasket(params)
    end
    @basket.save_changes
  else
    @basket.updateQuantity(params)
  end
  erb :"staff/selectproducts"
end


get '/staff/selectproducts' do
  @products = Products.all

  erb :"staff/selectproducts"
end

get '/staff/register' do
  erb :"staff/employeeregisterpage"
end

post '/staff/accounts' do
  @shown_accounts = Users.all
  erb :"staff/accounts"
end

get '/staff/accounts' do
  @shown_accounts = Users.all
  erb :"staff/accounts"
end

post '/staff/account' do
  @account = Users[params[:'account-data'].to_i]
  erb :"staff/account"
end

get '/staff/account' do
  @account = Users[params[:'account-data'].to_i]
  erb :"staff/account"
end

post '/staff/accounts/filter' do
  filter = h(params[:'search-filter'].to_s.strip)
  redirect '/staff/accounts' if filter.empty?

  @shown_accounts = Users.where(Username: filter).all
  redirect '/staff/accounts' if @shown_accounts.empty?

  erb :"staff/accounts"
end

post '/staff/generatelabel' do
  @account = Users[params[:'account-data'].to_i]
  erb :"staff/generatelabel"
end

post '/staff/settings' do
  erb :"staff/settings"
end

get '/staff/settings' do
  erb :"staff/settings"
end

get '/staff/orders' do
  @shown_orders = Transactions.all

  erb :'admin/orders'
end


get '/staff/managestock' do
  @products = Products.all

  @alert_message = case params[:error]
                   when 'invalid_name'  then 'Please enter a valid product name.'
                   when 'invalid_stock' then 'Please enter a valid stock quantity.'
                   when 'invalid_price' then 'Please enter a valid price.'
                   when 'invalid_image' then 'Please enter a valid image URL.'
                   when 'invalid_description' then 'Please enter a valid description.'
                   end

  erb :"staff/managestock"
end

# post '/staff/managestock' do
#   values_hash = {
#     product: Products[params['product_id']],
#     # Sanitise the input before updating the database
#     name: sanitise_string(params['product_name']),
#     stock: sanitise_int(params['product_stock']),
#     price: sanitise_price(params['product_price']),
#     image: sanitise_string(params['product_image']),
#     description: sanitise_string(params['product_description'])
#   }
#   update_product_values(values_hash)
#
#   redirect '/staff/managestock'
# end

post '/staff/save_coffee_choices' do
  session[:milkType] = params[:milkType]
  session[:coffeeSize] = params[:Size]
  if params[:Size] == 'Small'
    params[:totalcost] -= 1
  elsif params[:Size] == 'Large'
    params[:totalcost] += 1
  end

  if params[:milkType] == 'Soy Milk'
    params[:totalcost] += 1
  elsif params[:milkType] == 'Oat Milk'
    params[:totalcost] += 2
  end
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
        Price: params[:price].to_f.round(2),
        ProductImage: params[:image],
        ProductDescription: params[:description]
      )
    else
      redirect '/staff/managestock?error=invalid_name'
    end
  else
    product_error_message(params)
  end
end

# Return an appropriate error message if any input user input is invalid
def product_error_message(params)
  if params[:name]
    redirect '/staff/managestock?error=invalid_name'
  elsif params[:stock]
    redirect '/staff/managestock?error=invalid_stock'
  elsif params[:price]
    redirect '/staff/managestock?error=invalid_price'
  elsif params[:image]
    redirect '/staff/managestock?error=invalid_image'
  elsif params[:description]
    redirect '/staff/managestock?error=invalid_description'
  end
end

get '/staff/basketpayment' do
  erb :"staff/basketpayment"
end

post '/staff/thankyoupage' do
  transaction = Transactions.insert(
    UserId: params[:accountnum],
    TotalCost: params[:totalcost],
    Address: params[:address],
    TransactionDate: Time.now.strftime('%d%m%Y').to_i,
    Status: 'Pending',
    RefundRequested: false
  )

  transaction = Transactions[transaction]

  Basket.orderPlaced(transaction.UserId, transaction.TransactionId)

  Users.beanLoyaltyPointIncrease(params[:accountnum])

  erb :"staff/thankyoupage"
end

post '/staff/staffaccountview/filter' do
  unless params[:'search-filter'].empty?
    @shown_accounts = []
    @shown_accounts << Users.where(Username: params[:'search-filter'].to_s).get(:UserId)
  end
  redirect '/staff/staffaccountview'
end

post '/staff/view' do
  erb :"staff/account"
end

post '/staff/shop/add' do
  @products = Products.all
  Basket.add(params)

  redirect '/staff/selectproducts'
end

post '/staff/shop/subtract' do
  @products = Products.all
  Basket.subtract(params)

  redirect '/staff/selectproducts'
end

post '/staff/shop/delete' do
  @products = Products.all
  Basket.RemoveItem(params)

  redirect '/staff/selectproducts'
end

post '/staff/editpoints' do
  @account.update(LoyaltyPoints: h(params[:'points'])) unless params[:'points'].empty?
end
