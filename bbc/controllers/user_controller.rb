require 'sinatra'

get "/public" do
    erb :landingpage
end

get "/user/:name" do
    @username = params[:name]
    @coffeeprog = 1
    erb :userhomepage
end