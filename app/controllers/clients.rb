get '/clients' do
  redirect "/login" unless session[:user_id]
  erb :clients
end