require 'sinatra'

get "/" do
  redirect "/public"
end

get "/login" do
    erb :loginpage
end

post "/login" do
    username = params[:uname]
    password = params[:pword]

    if username == "test" && password == "test"
      "Logged in successfully!"
    else
      redirect "/login"
    end
end
