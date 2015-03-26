get "/profile" do
  puts "session[:user_id]? #{session[:user_id]}"

  redirect "/login" unless session[:user_id]
  @user = User.find(session[:user_id])
  puts "user is logged in #{@user.name} is confirmed? #{@user.confirmed}"
  #if @user.confirmed
  redirect "/start"
  #end
end


get "/login" do
  @errors = []

  if session[:user_id]
    redirect "/profile"
  else
    erb :login, :layout => :min_layout
  end
end

post "/login" do
  @errors = []
  @user = User.find_by(name: params[:username])
  if @user

    if @user.authenticate(params[:password])
      session[:user_id] = @user.id
      if @user.confirmed
        redirect "/profile"
      else
        @errors << "Email has not been confirmed"
      end
    else
      @errors << "Invalid password"
    end
  else
    @errors << "Invalid username"
  end
  erb :login, :layout => :min_layout
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
  @callback_method = "/send_confirmation_email"
  erb :new_user, :layout => :min_layout
end

post '/send_confirmation_email' do
  puts "/send_confirmation_email params #{params}"
  user = User.new
  user.name = params[:username]
  user.email = params[:email]
  user.password = params[:password]
  user.confirmed = false
  user.user_type = USER

  if user.save
    # success.   redirect and send email
    puts "new user created username: #{user.name} email: #{user.email} confirmed: #{user.confirmed}.  send email to confirm."  
    Log.new_entry "new user pending #{user.name} awaiting confirmaion #{user.email}"  
    #send email

    email = Mailer.send_new_user_link(
      user.email,
      user.name
    )
    email.deliver
    retval = "Confirmation email has been sent."
  else
    retval = "Unable to create new user."
  end
  retval
end

get '/confirm_new_user' do
  puts "/confirm_new_user #{params}"
  if @user = User.find_by(name: params[:id])
    @user.confirmed = true
    @user.save
    session.clear 
    Log.new_entry "new user  #{@user.name}  has been confirmed #{@user.email}"  
    redirect "/login"
  end
  "unable to confirm user"
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
