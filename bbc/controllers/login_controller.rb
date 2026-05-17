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
        redirect "/#{Users[user_id].AccountType}/homepage" if session[:userId]
      else
        @matching_error = 'Username or password are incorrect'
      end
    end
  else
    @matching_error = 'Username or password are incorrect'
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
  Basket.clearGuestBasket

  redirect '/login'
end
