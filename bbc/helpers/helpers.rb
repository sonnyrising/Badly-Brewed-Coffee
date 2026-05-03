require_relative "validation"
# ... Add "require" statements for your own helpers here ...

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  # ... Add your own helper modules here ...
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def current_user
    @current_user ||= Users.where(UserId: session[:userId])
  end

  def logged_in?
    !!current_user
  end

  def admin?
    logged_in? #Add check for admin.
  end

  def protected!
    halt 401, "Not authorized" unless logged_in?
  end

  def admin_protected!
    halt 403, "Admins only" unless admin?
  end

  # Helper method to update the values of the product table
  def update_product_values(params)
    # Check all inputs are valid
    if params[:name] && params[:stock] && params[:price] && params[:image] && params[:description] &&
       params[:origin] && params[:roast] && params[:type]
      # Update the product
      is_bean = (params[:type] == "Bean")

      if params[:product]
        params[:product].update(
          ProductName: params[:name],
          StockQuantity: params[:stock],
          Price: params[:price],
          ProductImage: params[:image],
          ProductDescription: params[:description],
          Origin: params[:origin],
          Roast: params[:roast],
          Bean: is_bean
        )
      else
        redirect "/managestock?error=invalid_name"
      end
    else
      product_error_message(params)
    end
  end

  # Return an appropriate error message if any input user input is invalid
  def product_error_message(params)
    if !params[:name]
      redirect "/managestock?error=invalid_name"
    elsif !params[:stock]
      redirect "/managestock?error=invalid_stock"
    elsif !params[:price]
      redirect "/managestock?error=invalid_price"
    elsif !params[:image]
      redirect "/managestock?error=invalid_image"
    elsif !params[:description]
      redirect "/managestock?error=invalid_description"
    elsif !params[:origin]
      redirect "/managestock?error=invalid_origin"
    elsif !params[:roast]
      redirect "/managestock?error=invalid_roast"
    elsif !params[:type]
      redirect "/managestock?error=invalid_type"
    end
  end

  # Helper Methods to sanitise the database entries
  def sanitise_price(input)
    return false if input.nil?

    # Ensure the input is a valid positive number
    # Uses a regex to allow for decimal values
    if input.match?(/^\d+(\.\d+)?$/) && input.to_f > 0
      return '%.2f' % input.to_f
    else
      return false
    end
  end

  def sanitise_int(input)
    return false if input.nil?

    # Ensure the input is an integer greater than 0
    if (input.to_i.to_s == input) && (input.to_i > 0)
      return input.to_i
    else
      return false
    end
  end

  def sanitise_string(input)
    return false if input.nil? || input.to_s.strip.empty?

    # Check for any SQL injection attempts
    if (input.include?("'") || input.include?('"') || input.include?(";") || input.include?("="))
      return false
    else
      return input
    end
  end

  def check_type(input)
    unless input == "Bean" || input == "Coffee"
      return false
    end
    return input
  end

  # Helper method to format an integer as a date
  def format_date(date_int)
    return false if date_int.nil?

    # Converts to a string and pads with zeros to ensure 8 characters
    date_str = date_int.to_s.rjust(8, '0')
    # Adds a slash to format as dd/mm/yyyy
    "#{date_str[0..1]}/#{date_str[2..3]}/#{date_str[4..7]}"
  end

  # Helper method to return the data needed for the main pie chart
  def get_pie_chart_data
    product_names = Products.all.map { |product| product.ProductName }

  end

  # Helper method to count the number of free coffees redeemed
  def get_free_coffees_redeemed
    users = Users.all
    free_coffees = 0
    users.each do |user|
      unless user.FreeCoffeesRedeemed.nil?
        free_coffees += user.FreeCoffeesRedeemed
      end
    end

    return free_coffees
  end

  def get_coffees_ordered(userID)
    transactions = Transactions.where(UserId: userID)
    count = 0

    transactions.each do |transaction|
      basket_items = Basket.where(TransactionId: transaction.TransactionId)

      basket_items.each do |item|
        count += item.Quantity
      end
    end

    return count
  end

  def get_loyalty_discount(userID)
    user = Users.where(UserId: userID)
    return user.get(:LoyaltyDiscount)
  end

  def get_quantity(transactionID)
    basket = Basket.where(TransactionId: transactionID)
    return basket.get(:Quantity)
  end

  def find_top_customers
    top_customers = []
    customers = Users.all
    customers.each do |customer|
      top_customers << User.new(customer.UserId, customer.Username)
    end

    top_customers.sort_by! { |user| user.total_spent }.reverse!
    return top_customers
  end

  def find_top_products
    top_products = []
    products = Products.all
    products.each do |product|
      top_products << Product.new(product.ProductId, product.ProductName)
    end

    top_products.sort_by! { |product| product.quantity_sold }.reverse!
    return top_products
  end

  def find_top_coffees
    top_coffees = []
    products = Products.where(Bean: false)
    products.each do |product|
      top_coffees << Product.new(product.ProductId, product.ProductName, product.Price)
    end

    top_coffees.sort_by! { |product| product.quantity_sold }.reverse!
    return top_coffees
  end

  def find_top_beans
    top_beans = []
    products = Products.where(Bean: true)
    products.each do |product|
      top_beans << Product.new(product.ProductId, product.ProductName, product.Price)
    end

    top_beans.sort_by! { |product| product.quantity_sold }.reverse!
    return top_beans
  end
end

# ---------| Helper Classes |---------
class User
  attr_accessor :user_id, :username, :total_spent

  def initialize(userID, username)
    @user_id = userID
    @username = username
    @total_spent = 0

    transactions = Transactions.where(UserId: @user_id, RefundRequested: false)
    transactions.each do |transaction|
      @total_spent += transaction.TotalCost
    end
  end
end

class Product
  attr_accessor :product_name, :quantity_sold, :price

  def initialize(product_id, product_name, price)
    @product_id = product_id
    @product_name = product_name
    @price = price
    @quantity_sold = 0


    baskets = Basket.where(ProductId: @product_id)
    baskets.each do |basket|
      @quantity_sold += basket.Quantity
    end
  end
end


