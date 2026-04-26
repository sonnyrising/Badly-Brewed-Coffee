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
    if !params[:name]
      redirect "/manager/managestock?error=invalid_name"
    elsif !params[:stock]
      redirect "/manager/managestock?error=invalid_stock"
    elsif !params[:price]
      redirect "/manager/managestock?error=invalid_price"
    elsif !params[:image]
      redirect "/manager/managestock?error=invalid_image"
    elsif !params[:description]
      redirect "/manager/managestock?error=invalid_description"
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
    return false if input.nil?

    # Check for any SQL injection attempts
    if (input.include?("'") || input.include?('"') || input.include?(";") || input.include?("="))
      return false
    else
      return input
    end
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
  users = Users.all
  free_coffees = 0
  users.each do |user|
    if !user.FreeCoffeesRedeemed.nil?
     free_coffees += user.FreeCoffeesRedeemed
    end
  end

end


