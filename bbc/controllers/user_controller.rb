before "/user/*" do
  protected!
end

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
  item_bought = @basket.hasBeenBought(params)

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

  Users.beanLoyaltyPointIncrease(transaction.UserId)

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
      return erb :"/refunds"
    else
      return erb :"user/feedback_page_submission"
    end
  else
    @alert_message = "Something went wrong while saving. Please try again!"
    return erb :"user/contact_us_page"
  end
end