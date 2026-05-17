# frozen_string_literal: true

get '/register' do
  erb :registerpage
end

post '/register' do
  @form_was_submitted = !params.empty?

  @user = Users.new
  @user.load(params)

  @uname = params.fetch('uname', '').strip
  @email = params.fetch('email', '').strip
  @pword = params.fetch('pword', '').strip
  @confirmpword = params.fetch('confirmpword', '').strip

  if @form_was_submitted
    existing_email = Users.where(Email: @email).first
    
    @uname_error = 'Please enter a username' if @uname.empty?
    @password_error = 'Please enter a password' if @pword.empty?
    @confirmpassword_error = 'Please enter your password again' if @confirmpword.empty?

    if !str_email_address?(@email)
      @email_error = 'Please enter a valid email'
    elsif existing_email
      @email_error = 'This email is already registered to another account'
    end

    @pword_match_error = 'Passwords dont match' if @pword != @confirmpword
    unless @pword.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[[:^alnum:]]).{8,}$/)
      @invalid_pword = 'Password must contain contain lower and upper case letters, a digit, a special character and be at least 8 characters long'
    end
    @taken_username = 'That username is already taken, try a different one' if @user.compareUsername(@uname)

    unless @uname_error.nil? && @email_error.nil? && @password_error.nil? && @confirmpassword_error.nil? && @pword_match_error.nil? && @invalid_pword.nil? && @taken_username.nil?
      @submission_error = 'Please correct the errors below'
    end

    if @submission_error.nil?
      session[:uname] = @uname
      @user.save_changes
      session[:userId] = Users.GetUserId(@uname)
      redirect '/user/homepage'
    end
  end

  erb :registerpage
end
