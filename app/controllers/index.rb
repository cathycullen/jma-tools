get '/' do
  redirect "/profile"
end

get "/start" do
  redirect "/login" unless session[:user_id]
    categories
    coaches
    url_root
  erb :start
end
