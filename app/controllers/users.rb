get "/profile" do
  puts "session[:user_id]? #{session[:user_id]}"

  redirect "/login" unless session[:user_id]
  @user = User.find(session[:user_id])
  puts "user is logged in #{@user.name}"
  redirect "/start"
end


get "/login" do
  if session[:user_id]
    redirect "/profile"
  else
    erb :login, :layout => :min_layout
  end
end

post "/login" do
  @user = User.find_by(name: params[:username])

  if @user.authenticate(params[:password])
    session[:user_id] = @user.id
    redirect "/profile"
  else
    @error = "Invalid username or password"
    erb :login, :layout => :min_layout
  end
end

get "/logout" do
  session.clear
  redirect "/login"
end

post "/logout" do
  session.clear
  redirect "/login"
end



get '/new_user' do
  @callback_method = "/create_new_user"
  erb :new_user, :layout => :min_layout
end

post '/create_new_user' do
  #read params and create new user
  puts "/create_new_user params #{params}"
  user = User.new
  user.name = params[:username]
  user.email = params[:email]
  user.password = params[:password]

  if user.save
    # success.   redirect and send email
    puts "new user created #{user.name}"  
    Log.new_entry "new user created #{user.name}"  
    redirect "/"
  else
    # fail redirect with error message

      puts "Error saving new user #{user.name}"
      @on_complete_msg = "Error saving new user #{user.name}"
      @on_complete_redirect=  "/"
      @on_complete_method=  "get"
      erb :done
    end

end
