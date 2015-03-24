get '/' do
  redirect "/profile"
end

get "/start" do
    categories
    coaches
    url_root
  erb :start
end
