get "/login" do
  session.clear
  erb :loginpage
end

post "/login" do
  @uname = params.fetch("uname", "").strip
  @password = params.fetch("pword", "").strip

  @uname_error = @uname.empty? ? "Please enter a username" : nil
  @pword_error = @password.empty? ? "Please enter a password" : nil
  @matching_error = nil

  if @uname == "manager" && @password == "manager"
    session[:uname] = @uname
    puts "Login. Session username: " + session[:uname]
    redirect "/manager/homepage"
    puts "Redirecting"
  elsif @uname == "staff" && @password == "staff"
    session[:uname] = @uname
    redirect "/staff/homepage"
  elsif @uname == "admin" && @password == "admin"
    session[:uname] = @uname
    session[:userId] = 1
    redirect "/admin"
  else
    userId = Users.GetUserId(@uname)
    if !userId.nil?
      if Users.isSuspended?(userId)
        @matching_error = "Account suspended due to inactivity for more than 6 months. Please contact support."
        return erb :loginpage
      else
        @password_validated = Users.ComparePassword(userId, @password)
        if @password_validated
          Users.SetDaysSinceLastUse(userId)
          session[:userId] = userId
          session[:uname] = @uname
          redirect "/user/homepage" unless !session[:userId]
        else
          @matching_error = "Username or password are incorrect"
        end
      end
    else
        @matching_error = "Username or password are incorrect"
    end
  end

  erb :loginpage
end

get "/forgotpassword" do
  erb :forgotpassword
end

get "/logout" do
  redirect "/login"
end