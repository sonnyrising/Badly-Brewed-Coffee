before "/user/*" do
  protected!
end

get "/user/homepage" do
  @shown_orders = Transactions.where(UserId: session[:userId]).all


  latest_transaction = Transactions.where(UserId: session[:userId]).order(:TransactionId).last

  if latest_transaction
    @transaction_date = latest_transaction.TransactionDate.to_s
    @formatted_date = "#{@transaction_date[0..1]}/#{@transaction_date[2..3]}/#{@transaction_date[4..7]}" 
    
    @recent_items = Basket.join(:Products, :ProductId => :ProductId).where(TransactionId: latest_transaction.TransactionId).all

    @calculated_total = @recent_items.sum { |item| item[:Price] * item.Quantity }
  else
    @recent_items = []
  end

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

get "/user/coffeeshop" do
   @products = Products.all

   erb :"user/coffeeSelect"
end

post "/user/shop" do
  @products = Products.all
  @basket = Basket.new

  exists = @basket.productExists(params)
  user_exists = @basket.userCheck(params)
  product_exists = @basket.productCheck(params)
  item_bought = @basket.bought(params)

  if !item_bought.nil?
    latest_product = @basket.checkLatest(params)
    if latest_product.nil?
      @basket.addToBasket(params)
      @basket.save_changes
    else 
      @basket.updateQuantity(params)
    end
  elsif exists.nil? || user_exists.nil? || product_exists.nil?
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
  @all_transactions = Transactions.where(UserId: session[:userId]).order(Sequel.desc(:TransactionId)).all

  @orders_with_items = {}

  @all_transactions.each do |transaction|
    @orders_with_items[transaction.TransactionId] = Basket.join(:Products, :ProductId => :ProductId).where(TransactionId: transaction.TransactionId).all
  end
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
  transaction = Transactions.insert(
    UserId: params[:userId],
    TotalCost: params[:totalcost].to_f.round(2),
    Address: params[:address],
    TransactionDate: Time.now.strftime("%d%m%Y").to_i,
    Status: "Pending",
    RefundRequested: false
  )

  transaction = Transactions[transaction]

  Basket.orderPlaced(transaction.UserId, transaction.TransactionId)

  Users.beanLoyaltyPointIncrease(params[:userId])

  erb :"user/thankyoupage"
end

post "/user/feedback-page-submit" do
  @feedback = Feedbacks.new
  @feedback.load(params)
  @feedback.UserId = session[:userId]

  if params[:request] == "Yes"
    transaction = Transactions.where(TransactionId: @feedback.TransactionId).first

    if transaction.nil?
      @alert_message = "Transaction ID not found. Please try again!"
      return erb :"user/contact_us_page"

    elsif transaction.Refunded == true
      @alert_message = "This transaction has already been refunded. Please try again!"
      return erb :"user/contact_us_page"

    elsif transaction.RefundRequested == true
      @alert_message = "This transaction has already been requested for a refund. Please try again!"
      return erb :"user/contact_us_page"
      
    end
  end
  
  if @feedback.save_changes
    @feedback_text = h(@feedback.IssueContent)
    @refund_reason = h(@feedback.RefundReason)

    if params[:request] == "Yes"
      Transactions.where(TransactionId: @feedback.TransactionId).update(RefundRequested: true)
    end

    if session[:uname] == 'manager' || session[:uname] == 'staff'
      @refunds = Transactions.where(RefundRequested: true).all
      redirect :"/refunds"
    else
      redirect :"user/feedback_page_submission"
    end
  else
    @alert_message = "Something went wrong while saving. Please try again!"
    return erb :"user/contact_us_page"
  end
end
