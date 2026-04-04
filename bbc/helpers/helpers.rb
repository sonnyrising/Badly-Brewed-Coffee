require_relative "validation"
# ... Add "require" statements for your own helpers here ...

# Register helpers with Sinatra
helpers do
  # This is so that we get to use the "h" method in views
  include ERB::Util

  # This is so that we include useful validation methods
  include Validation

  # ... Add your own helper modules here ...

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
end
