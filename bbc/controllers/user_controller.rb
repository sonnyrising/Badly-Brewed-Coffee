require 'sinatra'

get "/public" do
    erb :publichomepage
end

get "/public/:name"