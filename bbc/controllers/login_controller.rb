# frozen_string_literal: true

get '/login' do
  session.clear
  erb :loginpage
end

post '/login' do
  @uname = params.fetch('uname', '').strip
  @password = params.fetch('pword', '').strip

  @uname_error = @uname.empty? ? 'Please enter a username' : nil
  @pword_error = @password.empty? ? 'Please enter a password' : nil
  @matching_error = nil

  if @uname == 'Manager' && BCrypt::Password.new('$2a$12$9CBEK/IV6GtNCFW8AG1qVOJ66zx8Q3he3YQlMvcLa8r1vzboQSKei') == @password
    session[:uname] = @uname.downcase
    puts "Login. Session username: #{session[:uname]}"
    redirect '/manager/homepage'
    puts 'Redirecting'
  elsif @uname == 'Staff' && BCrypt::Password.new('$2a$12$nW2DIockRWPhi90But102OUMRXYR7/LCQRdUbH771UlqS2Zwan7O6') == @password
    session[:uname] = @uname.downcase
    redirect '/staff/homepage'
  elsif @uname == 'Admin' && BCrypt::Password.new('$2a$12$sK6oWkCNEDorTY00zHArXOV7O/4iA3DMsQagqYVJ6DVT9F2jCrONq') == @password
    session[:uname] = @uname.downcase
    session[:userId] = 1
    redirect '/admin/homepage'
  else
    user_id = Users.GetUserId(@uname)
    if !user_id.nil?
      if Users.isSuspended?(user_id)
        @matching_error = 'Account suspended due to inactivity for more than 6 months. Please contact support.'
        return erb :loginpage
      else
        @password_validated = Users.ComparePassword(user_id, @password)
        if @password_validated
          Users.SetDaysSinceLastUse(user_id)
          session[:userId] = user_id
          session[:uname] = @uname
          redirect '/user/homepage' if session[:userId]
        else
          @matching_error = 'Username or password are incorrect'
        end
      end
    else
      @matching_error = 'Username or password are incorrect'
    end
  end

  erb :loginpage
end

post '/guestlogin' do
  session[:userId] = 1
  session[:uname] = 'Guest'
  redirect '/user/homepage'

  erb :loginpage
end

get '/forgotpassword' do
  erb :forgotpassword
end

get '/logout' do
  session.clear
  Users.clearGuestBasket

  redirect '/login'
end
