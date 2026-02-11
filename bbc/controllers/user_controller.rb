require 'sinatra'

get "/public" do
    erb :publichomepage
end

get "/public/:name" do
    'Hello, your name is #{params[:name]}!'
end