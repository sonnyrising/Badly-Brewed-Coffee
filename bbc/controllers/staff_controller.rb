before "/staff/*" do
  if session[:uname] != "staff"
    redirect "/"
  end
end

get "/staff/homepage" do
  erb :"staff/homepage"
end

post "/staff/selectproducts" do
  @products = Products.all

  erb :"staff/selectproducts"
end

get "/staff/selectproducts" do
  @products = Products.all

  erb :"staff/selectproducts"
end

get "/staff/register" do
  erb :"staff/employeeregisterpage"
end

post "/staff/staffaccountview" do
  erb :"staff/staffaccountview"
end

get "/staff/staffaccountview" do
  erb :"staff/staffaccountview"
end

post "/staff/generatelabel" do
  erb :"staff/generatelabel"
end

post "/staff/settings" do
  erb :"staff/settings"
end

get "/staff/settings" do
  erb :"staff/settings"
end

post "/staff/basketpayment" do
  erb :"staff/basketpayment"
end

post "/staff/thankyoupage" do
  erb :"staff/thankyoupage"
end

post "/staff/staffaccountview/filter" do
  if !params[:'search-filter'].empty?
    @shown_accounts = []
    @shown_accounts << Users.where(Username: "#{params[:'search-filter']}").get(:UserId)
    redirect "/staff/staffaccountview"
  else
    redirect "/staff/staffaccountview"
  end
end

post "/staff/view" do
  erb :"staff/account"
end

post "/staff/shop/add" do
  @products = Products.all
  Basket.add(params)

  redirect "/staff/selectproducts"
end

post "/staff/shop/subtract" do
  @products = Products.all
  Basket.subtract(params)

  redirect "/staff/selectproducts"
end

post "/staff/shop/delete" do
  @products = Products.all
  Basket.RemoveItem(params)

  redirect "/staff/selectproducts"
end