require 'sinatra'

get "/public" do
    erb :landingpage
end

get "/user/:name" do
    @name = params[:name]
    erb :userhomepage
end

get "/user/settings" do
  erb :settingspage
end

get "/user/selectproducts" do
  erb :selectproducts
end

get "/user/orderhistory" do
  erb :orderhistory
end

get "/user/thankyoupage" do
  erb :thankyoupage
end

