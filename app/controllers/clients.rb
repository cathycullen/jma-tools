get '/clients' do
  redirect "/login" unless session[:user_id]
  @clients = Client.all.order('name asc')
  erb :clients
end

get '/edit_client' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @submit_callback = "/save_client"
  if !params[:id].nil?
    @client = Client.find(params[:id])
    @client_id = params[:id]
  end
  erb :edit_client
end

post '/save_client' do
  redirect "/login" unless session[:user_id]
  @errors = []
  
  if !params[:id].nil?
    @client_id = params[:id]
    @client = Client.find(@client_id)
    if @client
        @client.name = params[:name]
        @client.phone = params[:phone]
        @client.email = params[:email]
        @client.address = params[:address]
        @client.city = params[:city]
        @client.state = params[:state]
        @client.zip = params[:zip]
        @client.phone = params[:phone]
        @client.category_id = params[:category_id]
        @client.coach_id = params[:coach_id]

        puts "saving client:  #{@client.name} #{@client.address}"
        Log.new_entry "Edit Client data saved #{@client.name}"
        @client.save
      end
    end

    @on_complete_msg = "client Information Saved."
    @on_complete_redirect=  "/clients"
    @on_complete_method=  "get"
    erb :done
  end

