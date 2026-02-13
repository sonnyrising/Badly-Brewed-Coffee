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