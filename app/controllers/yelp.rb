
  get '/yelp_request' do
    redirect "/login" unless session[:user_id]
    @template = "yelp_request"
    @preview_callback_method = "/yelp_request_preview"
    @send_callback_method = "/yelp_request_send"
    @submit_callback = '/yelp_request_preview'
    erb :yelp_request_template
    #, :layout => false
  end

  post '/yelp_request_preview' do
    @name = params[:name]
    @email = params[:email]
    @template = "yelp_request_template"
    @send_callback_method = "/send_yelp_request"
    erb :yelp_request_preview, :layout => false
  end

  post '/send_yelp_request' do

    @name = params[:name]
    @email = params[:email]
    email = Mailer.send_yelp_request(
      @name,
      @email
    )
    email.deliver
    @on_complete_msg = "Yelp Review Request Email Sent."
    @on_complete_redirect=  "/done"
    @on_complete_method=  "post"
    erb :done
  end
