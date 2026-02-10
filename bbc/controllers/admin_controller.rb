require 'sinatra'

get "/admin" do
    erb :adminhomepage
end

get "/admin/login" do
    'Admin login!'
end