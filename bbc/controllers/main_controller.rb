require 'sinatra'

get "/" do
  redirect "/public"
end

get "/login" do
    erb :loginpage
end

post "/login" do
    "Recieved login information!"
end
