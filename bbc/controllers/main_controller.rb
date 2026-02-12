require 'sinatra'

get "/" do
    redirect "/public"
end

get "/login" do
    'Login page!'
end
