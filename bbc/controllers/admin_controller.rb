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
  options = params["filter"]
  if options == "refund"
    @shown_feedback = Feedbacks.where(RefundRequest: "Yes").all
  else
    @shown_feedback = Feedbacks.all
  end

  erb :"admin/feedback"
end

get "/admin/run-inactivity-check" do
  validate_session
  Users.daily_inactivity_check
  redirect "/admin/accounts"
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
  feedback_id = params[:feedbackId]
  Feedbacks.where(FeedbackId: feedback_id).delete

  redirect "/admin/feedback"
end

post "/admin/accounts/create" do
  erb :"admin/accountcreation"
end

post "/admin/accounts/create/submit" do
  @user_id = 1
  @password = BCrypt::Password.create("password")
  puts params[:'type-data']
  if(params[:'type-data'] == "Staff")
    puts "Creating a staff account!"
    @user_id = validate_staff_id(@user_id)
    Staff.insert(StaffId: @user_id, StaffUsername: "#{params[:'username-data']}", StaffEmail: "#{params[:'email-data']}", StaffPasswordHash: @password, EmployeeLevel: 'Barista', EmploymentStatus: 1)
  else
    puts "Creating a user account!"
    @user_id = validate_user_id(@user_id)
    Users.insert(UserId: @user_id, Username: "#{params[:'username-data']}", PassHash: @password, Email: "#{params[:'email-data']}", LoyaltyPoints: 0, DaysSinceLastUse: 0, Suspended: 0)
  end
  redirect "/admin/accounts"
end

def validate_staff_id(user_id)
  if Staff.where(StaffId: user_id).empty?
    return user_id
  else
    validate_staff_id(user_id += 1)
  end
end

def validate_user_id(user_id)
  if Users.where(UserId: user_id).empty?
    return user_id
  else
    validate_user_id(user_id + 1)
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
  @user_id= params[:userId]
  erb :"admin/account"
end

post "/admin/accounts/edit" do
  @user_id= params[:userId]
  erb :"admin/accountedit"
end

post "/admin/accounts/edit/update" do
  user_id= params[:'id-data']

  if !params[:'username-data'].empty?
    Users.where(UserId: user_id).update(Username: "#{params[:'username-data']}")
  end
  if !params[:'email-data'].empty?
    Users.where(UserId: user_id).update(Email: "#{params[:'email-data']}")
  end
  if !params[:'loyaltypoint-data'].empty?
    Users.where(UserId: user_id).update(LoyaltyPoints: params[:'loyaltypoint-data'])
  end
  #if !params[:'address-data'].empty?
  #  Users.where(UserId: user_id).update(LoyaltyPoints: "#{params[:'username-data']}")
  #end
  if !params[:'inactivity-data'].empty?
    Users.where(UserId: user_id).update(DaysSinceLastUse: params[:'inactivity-data'])
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/edit/recover" do
  user_id= params[:'id-data']
  @password = BCrypt::Password.create("password")

  Users.where(UserId: user_id).update(PassHash: @password)

  redirect "/admin/accounts"
end

post "/admin/accounts/suspend" do
  @user_id= params[:userId]
  if !Users.isSuspended?(@user_id)
    Users.where(UserId: @user_id).update(Suspended: 1)
  else
    Users.where(UserId: @user_id).update(Suspended: 0)
  end

  redirect "/admin/accounts"
end

post "/admin/accounts/delete" do
  user_id= params[:userId]
  Users.where(UserId: user_id).delete
  Transactions.where(UserId: user_id).delete
  Feedbacks.where(UserId: user_id).delete
  Basket.where(UserId: user_id).delete

  redirect "/admin/accounts"
end

get "/admin/orders" do
  @shown_orders = Transactions.all

  erb :'admin/orders'
end

post "/admin/orders/filter" do
  if !params[:'search-filter'].empty? && !Transactions[params[:'search-filter']].nil?
    @shown_orders = []
    @shown_orders << Transactions[params[:'search-filter']]
    erb :'admin/orders'
  else
    redirect "/admin/orders"
  end
end

post "/admin/orders/edit" do
  erb :'admin/orderedit'
end

post "/admin/orders/delete" do

end
