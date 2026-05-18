# frozen_string_literal: true

before '/user/*' do
  protected!
end

get '/user/homepage' do
  @shown_orders = Transactions.where(UserId: session[:userId]).all


  latest_transaction = Transactions.where(UserId: session[:userId]).order(:TransactionId).last

  if latest_transaction
    @transaction_date = latest_transaction.TransactionDate.to_s
    @formatted_date = "#{@transaction_date[0..1]}/#{@transaction_date[2..3]}/#{@transaction_date[4..7]}"

    @recent_items = Basket.join(:Products,
                                ProductId: :ProductId).where(TransactionId: latest_transaction.TransactionId).all

    @calculated_total = @recent_items.sum { |item| item[:Price] * item.Quantity }
  else
    @recent_items = []
  end

  erb :"user/homepage"
end

post '/user/homepage' do
  erb :"user/homepage"
end

get '/user/settings' do
  @user = Users.where(UserId: session[:userId]).first

  @success_message = session.delete(:success_message)
  @error_message = session.delete(:error_message)


  erb :"user/settings"
end

post '/user/update_settings' do
  new_username = params[:username]
  new_email = params[:email]
  current_user_id = session[:userId]

  existing_user = Users.where(Username: new_username).exclude(UserId: current_user_id).first
  existing_email = Users.where(Email: new_email).exclude(UserId: current_user_id).first

  if existing_user
    session[:error_message] = "Sorry, the username '#{new_username}' is already taken!"  
  elsif existing_email
    session[:error_message] = "Sorry, the email '#{new_email}' is already taken!"
  else
    Users.where(UserId: session[:userId]).update(Username: new_username, Email: new_email)

    session[:uname] = new_username
    session[:success_message] = 'Account details successfully updated!'
  end
  redirect '/user/settings'
end

get '/user/shop' do
  @products = Products.all

  erb :"user/selectproducts"
end

get '/user/coffeeshop' do
  @products = Products.all

  erb :"user/coffeeSelect"
end

post '/user/shop' do
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

  if Products.coffeeOrBeans(params) == true
    erb :"user/selectproducts"
  else
    erb :"user/coffeeSelect"
  end
end

post '/user/shop/add' do
  @products = Products.all
  Basket.add(params)

  if Products.coffeeOrBeans(params) == true
    erb :"user/selectproducts"
  else
    erb :"user/coffeeSelect"
  end
end

post '/user/shop/subtract' do
  @products = Products.all
  Basket.subtract(params)

  if Products.coffeeOrBeans(params) == true
    erb :"user/selectproducts"
  else
    erb :"user/coffeeSelect"
  end
end

post '/user/shop/delete' do
  @products = Products.all
  Basket.RemoveItem(params)

  if Products.coffeeOrBeans(params) == true
    erb :"user/selectproducts"
  else
    erb :"user/coffeeSelect"
  end
end

post '/user/filterbeans' do
  
  roast_selected = params[:roast].to_s
  
  name_searched = params[:'search']
  if !name_searched.empty? || !roast_selected.empty?   
    @products = Products.all.select do |product|
      product.ProductName.to_s.downcase.include?(name_searched.downcase)
    end

    if roast_selected && !roast_selected.empty?
      @products = @products.select { |product| product.Roast.to_s == roast_selected }
    end
    erb :"user/selectproducts"

  elsif roast_selected && !roast_selected.empty?
    @products = Products.all.select do |product|
      product.Roast.to_s == roast_selected
    end
    erb :"user/selectproducts"  
    
  else
    redirect "/user/shop"
  end
end

post '/user/filtercoffees' do
  
  roast_selected = params[:roast]

  name_searched = params[:'search']
  if !name_searched.empty?
    @products = Products.all.select do |product|
      product.ProductName.to_s.downcase.include?(name_searched.downcase)
    end

    if roast_selected && !roast_selected.empty?
      @products = @products.select { |product| product.Roast.to_s == roast_selected }
    end
    erb :"user/coffeeSelect"
  
  elsif roast_selected && !roast_selected.empty?
    @products = Products.all.select do |product|
      product.Roast.to_s == roast_selected && (product.Bean == 0 || product.Bean == false || product.Bean == "0")
    end
    erb :"user/coffeeSelect"

  else
    redirect "/user/coffeeshop"
  end
end

get '/user/orders' do
  latest_transaction = Transactions.where(UserId: session[:userId]).order(:TransactionDate).last

  if latest_transaction
    @total_cost = latest_transaction.TotalCost
    @transaction_date = latest_transaction.TransactionDate.to_s
    @formatted_date = "#{@transaction_date[0..1]}/#{@transaction_date[2..3]}/#{@transaction_date[4..7]}"

    @recent_items = Basket.join(:Products,
                                ProductId: :ProductId).where(TransactionId: latest_transaction.TransactionId).all
  else
    @recent_items = []
  end

  @all_transactions = Transactions.where(UserId: session[:userId]).order(:TransactionId).reverse.all || []
  @orders_with_items = {}

  @all_transactions.each do |transaction|
    @orders_with_items[transaction.TransactionId] =
      Basket.join(:Products, ProductId: :ProductId).where(TransactionId: transaction.TransactionId).all
  end
  erb :"user/orderhistory"
end

get '/user/thankyoupage' do
  erb :"user/thankyoupage"
end

get '/user/contact_us_page' do
  erb :"user/contact_us_page"
end

get '/user/feedback_page_submission' do
  @feedback = Feedbacks.last || Feedbacks.new
  erb :"user/feedback_page_submission"
end

get '/user/basketpayment' do
  erb :"user/basketpayment"
end

post '/user/basketpayment' do
  erb :"user/basketpayment"
end

post '/thankyoupage' do
  transaction = Transactions.insert(
    UserId: params[:userId],
    TotalCost: params[:totalcost].to_f.round(2),
    Address: params[:address],
    TransactionDate: Time.now.strftime('%d%m%Y').to_i,
    Status: 'Pending',
    RefundRequested: false
  )

  transaction = Transactions[transaction]

  Basket.orderPlaced(transaction.UserId, transaction.TransactionId)
  userId = params[:userId]

  if params[:beans].to_i.positive?
    Users.beanLoyaltyPointIncrease(userId)
    basket = Basket.where(TransactionId: transaction.TransactionId)
    product = Products.where(ProductId: basket.get(:ProductId))
    quantity = basket.get(:Quantity)
    decrease_bean_stock(product.get(:ProductId), quantity)
  else
    Users.coffeeLoyaltyPointIncrease(userId)

    Users.pointsRedeemed(userId) if Users.get_loyalty_points(userId) >= 10
  end


  erb :"user/thankyoupage"
end

post '/user/feedback-page-submit' do
  @feedback = Feedbacks.new
  @feedback.load(params)
  @feedback.UserId = session[:userId]

  if params[:request] == 'Yes'
    transaction = Transactions.where(TransactionId: @feedback.TransactionId).first

    if transaction.nil?
      @alert_message = 'Transaction ID not found. Please try again!'
      return erb :"user/contact_us_page"

    elsif transaction.Refunded == true
      @alert_message = 'This transaction has already been refunded. Please try again!'
      return erb :"user/contact_us_page"

    elsif transaction.RefundRequested == true
      @alert_message = 'This transaction has already been requested for a refund. Please try again!'
      return erb :"user/contact_us_page"

    end
  end

  if @feedback.save_changes
    @feedback_text = h(@feedback.IssueContent)
    @refund_reason = h(@feedback.RefundReason)

    if params[:request] == 'Yes'
      Transactions.where(TransactionId: @feedback.TransactionId).update(RefundRequested: true)
    end

    if %w[manager staff].include?(session[:uname])
      @refunds = Transactions.where(RefundRequested: true).all
      redirect :"/refunds"
    else
      redirect :"user/feedback_page_submission"
    end
  else
    @alert_message = 'Something went wrong while saving. Please try again!'
    return erb :"user/contact_us_page"
  end
end
