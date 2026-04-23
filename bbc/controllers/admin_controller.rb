before "/admin/*" do
  if session[:uname] != "admin"
    redirect "/"
  end
end

get "/admin" do
  erb :"admin/homepage"
end

get "/admin/accounts" do
  @shown_accounts = Users.map(:UserId)
  erb :"admin/accounts"
end

get "/admin/views" do
  erb :'admin/viewselection'
end

post "/admin/views/manager" do
  erb :'manager/homepage'
end

post "/admin/views/barista" do
  erb :'staff/homepage'
end

post "/admin/views/user" do
  erb :'user/homepage'
end

get "/admin/feedback" do
  @shown_feedback = Feedbacks.map(:FeedbackId)

  if params["filter"] == "refund"
    @shown_feedback = Feedbacks.where(RefundRequest: true).all
  else
    @shown_feedback = Feedbacks.where(RefundRequest: false).all
  end

  erb :"admin/feedback"
end

get "/admin/run-inactivity-check" do
  validate_session
  Users.daily_inactivity_check
end

post "/admin/feedback/filter" do
  if !params[:'search-filter'].empty?
    @shown_feedback = []
    @shown_feedback << Feedbacks.where(FeedbackId: params[:'search-filter'].to_i).get(:FeedbackId)
    erb :"admin/feedback"
  else
    redirect "/admin/feedback"
  end
end

post "/admin/feedback/delete" do
  feedbackId = params[:feedbackId]
  Feedbacks.where(FeedbackId: feedbackId).delete

  redirect "/admin/feedback"
end

post "/admin/accounts/create" do
  erb :"admin/accountcreation"
end

post "/admin/accounts/create/submit" do
  @userId = 1
  @password = BCrypt::Password.create("password")
  puts params[:'type-data']
  if(params[:'type-data'] == "Staff")
    puts "Creating a staff account!"
    @userId = validate_staff_id(@userId)
    Staff.insert(StaffId: @userId, StaffUsername: "#{params[:'username-data']}", StaffEmail: "#{params[:'email-data']}", StaffPasswordHash: @password, EmployeeLevel: 'Barista', EmploymentStatus: 1)
  else
    puts "Creating a user account!"
    @userId = validate_user_id(@userId)
    Users.insert(UserId: @userId, Username: "#{params[:'username-data']}", PassHash: @password, Email: "#{params[:'email-data']}", LoyaltyPoints: 0, DaysSinceLastUse: 0, Suspended: 0)
  end
  redirect "/admin/accounts"
end

def validate_staff_id(userId)
  if Staff.where(StaffId: userId).empty?
    return userId
  else
    validate_staff_id(userId += 1)
  end
end

def validate_user_id(userId)
  if Users.where(UserId: userId).empty?
    return userId
  else
    validate_user_id(userId + 1)
  end
end

post "/admin/accounts/filter" do
  if !params[:'search-filter'].empty?
    @shown_accounts = []
    @shown_accounts << Users.where(Username: "#{params[:'search-filter']}").get(:UserId)
    erb :"admin/accounts"
  else
    redirect "/admin/accounts"
  end
end

post "/admin/accounts/view" do
  @userId = params[:userId]
  erb :"admin/account"
end

post "/admin/accounts/edit" do
  @userId = params[:userId]
  erb :"admin/accountedit"
end

post "/admin/accounts/edit/update" do
  userId = params[:'id-data']

  if !params[:'username-data'].empty?
    Users.where(UserId: userId).update(Username: "#{params[:'username-data']}")
  end
  if !params[:'email-data'].empty?
    Users.where(UserId: userId).update(Email: "#{params[:'email-data']}")
  end
  if !params[:'loyaltypoint-data'].empty?
    Users.where(UserId: userId).update(LoyaltyPoints: params[:'loyaltypoint-data'])
  end
  #if !params[:'address-data'].empty?
  #  Users.where(UserId: userId).update(LoyaltyPoints: "#{params[:'username-data']}")
  #end
  if !params[:'inactivity-data'].empty?
    Users.where(UserId: userId).update(DaysSinceLastUse: params[:'inactivity-data'])
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/edit/recover" do
  userId = params[:'id-data']
  @password = BCrypt::Password.create("password")

  Users.where(UserId: userId).update(PassHash: @password)

  redirect "/admin/accounts"
end

post "/admin/accounts/suspend" do
  @userId = params[:userId]
  if !Users.isSuspended?(@userId)
    Users.where(UserId: @userId).update(Suspended: 1)
  else
    Users.where(UserId: @userId).update(Suspended: 0)
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/delete" do
  userId = params[:userId]
  Users.where(UserId: userId).delete
  Transactions.where(UserId: userId).delete
  Feedbacks.where(UserId: userId).delete
  Basket.where(UserId: userId).delete

  redirect "/admin/accounts"
end
