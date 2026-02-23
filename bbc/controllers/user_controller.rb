require 'sinatra'

get "/public" do
    erb :landingpage
end

get "/public/:name" do
    if params[:name] == "Steffan"
        "Hi, Steffan!"
    else
        "No entry I'm afraid!"
    end
end

get "/settings" do
  erb :settingspage
end

get "/selectproducts" do
  erb :selectproducts
end

get "/orderhistory" do
  erb :orderhistory
end