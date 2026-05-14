# frozen_string_literal: true

before '/admin/*' do
  redirect '/' if Users[session[:userId]].AccountType != 'admin'
end

get '/admin/homepage' do
  erb :"admin/homepage"
end

get '/admin/accounts' do
  @shown_accounts = Users.all
  erb :"admin/accounts"
end

get '/admin/views' do
  erb :'admin/viewselection'
end

post '/admin/views/manager' do
  redirect 'manager/homepage'
end

post '/admin/views/barista' do
  redirect '/staff/homepage'
end

post '/admin/views/user' do
  redirect '/user/homepage'
end

get '/admin/feedback' do
  @shown_feedback = Feedbacks.all
  erb :"admin/feedback"
end

post '/admin/run-inactivity-check' do
  Users.daily_acc_activity_check
  redirect '/admin/accounts'
end

post '/admin/feedback/filter' do
  if !params[:filter].nil? && params[:filter] == 'refund_issue'
    @shown_feedback = Feedbacks.where(RefundRequest: 'Yes').all
    erb :"admin/feedback"
  else
    redirect '/admin/feedback'
  end
end

post '/admin/feedback/delete' do
  feedback_id = params[:feedbackId]
  Feedbacks.where(FeedbackId: feedback_id).delete

  redirect '/admin/feedback'
end

post '/admin/accounts/create' do
  redirect '/admin/accounts/create'
end

get '/admin/accounts/create' do
  erb :"admin/accountcreation"
end

post '/admin/accounts/create/submit' do
  @user_id = 1
  @password = BCrypt::Password.create('password')
  puts params[:'type-data']
  if h(params[:'type-data']) == 'Staff'
    @user_id = validate_user_id(@user_id)
    Users.insert(UserId: @user_id, Username: params[:'username-data'].to_s,
                 PassHash: @password,Email: params[:'email-data'].to_s, AccountType: "staff")
  else
    @user_id = validate_user_id(@user_id)
    Users.insert(UserId: @user_id, Username: params[:'username-data'].to_s, PassHash: @password,
                 Email: params[:'email-data'].to_s, LoyaltyPoints: 0, DaysSinceLastUse: 0, Suspended: 0, AccountType: "user")
  end
  redirect '/admin/accounts'
end

def validate_user_id(user_id)
  return user_id if Users.where(UserId: user_id).empty?

  validate_user_id(user_id + 1)
end

post '/admin/accounts/filter' do
  filter = h(params[:'search-filter'].to_s.strip)
  redirect '/admin/accounts' if filter.empty?

  @shown_accounts = Users.where(Username: filter).all
  redirect '/admin/accounts' if @shown_accounts.empty?

  erb :"admin/accounts"
end

post '/admin/accounts/view' do
  @account = Users[params[:'account-data'].to_i]
  if @account
    erb :"admin/account"
  else
    redirect '/admin/accounts/view'
  end
end

get '/admin/accounts/view' do
  @account = Users[params[:'account-data'].to_i]
  erb :"admin/account"
end

post '/admin/accounts/edit' do
  id = params[:'account-data']
  redirect "admin/accounts/edit/#{id}"
end

get '/admin/accounts/edit/:id' do
  @account = Users[params[:id].to_i]
  if @account
    erb :"admin/accountedit"
  else
    redirect '/admin/accounts'
  end
end

post '/admin/accounts/edit/update' do
  @account = Users[h(params[:'account-data'].to_i)]

  @account.update(Username: h(params[:'username-data'].to_s)) unless params[:'username-data'].empty?
  @account.update(Email: h(params[:'email-data'].to_s)) unless params[:'email-data'].empty?
  @account.update(LoyaltyPoints: h(params[:'loyaltypoint-data'])) unless params[:'loyaltypoint-data'].empty?
  # if !params[:'address-data'].empty?
  #  Users.where(UserId: user_id).update(LoyaltyPoints: "#{params[:'username-data']}")
  # end
  @account.update(DaysSinceLastUse: h(params[:'inactivity-data'])) unless params[:'inactivity-data'].empty?

  redirect '/admin/accounts'
end

post '/admin/accounts/edit/recover' do
  @account = Users[h(params[:'account-data']).to_i]
  @password = BCrypt::Password.create('password')

  @account.update(PassHash: @password)

  redirect '/admin/accounts'
end

post '/admin/accounts/suspend' do
  @account = Users[params[:'account-data'].to_i]
  button_data = params[:'button-type-data']

  if button_data == 'end-warning'
    @account.update(Suspended: 0, Warning: 0, DaysSinceWarning: 0)

  elsif Users.isSuspended?(@account.UserId) # reinstate account status
    @account.update(Suspended: 0)

  elsif !Users.is_on_warning?(@account.UserId)
    @account.update(Warning: 1, DaysSinceWarning: 0)
  else
    @account.update(Suspended: 1, DaysSinceWarning: 0) # suspend if already on warning
  end

  redirect '/admin/accounts'
end

post '/admin/accounts/delete' do
  @account = Users[h(params[:'account-data']).to_i]
  if @account
    Transactions.where(UserId: @account.UserId).delete
    Feedbacks.where(UserId: @account.UserId).delete
    Basket.where(UserId: @account.UserId).delete

    @account.delete
  end
  redirect '/admin/accounts'
end

get '/admin/orders' do
  @shown_orders = Transactions.all

  erb :'admin/orders'
end

post '/admin/orders/filter' do
  if !params[:'search-filter'].empty? && !Transactions[params[:'search-filter']].nil?
    @shown_orders = []
    @shown_orders << Transactions[params[:'search-filter']]
    erb :'admin/orders'
  else
    redirect '/admin/orders'
  end
end

post '/admin/orders/edit' do
  @order = Transactions[h(params[:'transaction-id']).to_i]

  erb :'admin/orderedit'
end

post '/admin/orders/edit/update' do
  order = Transactions[h(params[:'order-data']).to_i]

  order.update(Address: h(params[:'address-data']).to_s) unless params[:'address-data'].empty?
  order.update(Refunded: h(params[:'refund-data']).to_s) unless params[:'refund-data'].empty?

  Logs.insert(UserId: session[:userId], LogDate: Time.now.strftime('%d/%m/%Y'),
              LogDescription: h(params[:'refund-reason']))

  redirect '/admin/orders'
end

post '/admin/orders/delete' do
  @order = Transactions[h(params[:'transaction-id']).to_i]
  @order.delete

  redirect '/admin/orders'
end

get '/admin/log' do
  @shown_logs = Logs.all
  erb :'admin/logpage'
end
