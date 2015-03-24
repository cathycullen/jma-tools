
get '/new_guest' do
  redirect "/login" unless session[:user_id]
  puts "/new_guest called #{params}"
  puts "client_types #{@client_types.inspect}"
  client_types

  @workshop_id = params[:workshop_id]
  @workshop = Workshop.find(@workshop_id)

  @errors = []
  @submit_callback = '/save_new_guest'
  erb :new_guest  
end

  get '/edit_guest' do
  redirect "/login" unless session[:user_id]
    client_types
    @errors = []
    @submit_callback = '/save_guest'
    if !params[:id].nil?
        @guest = Guest.find(params[:id])
      if @guest
        @workshop_id = @guest.workshop_id
        @workshop = Workshop.find(@workshop_id)
        puts "/edit_guest lunch:  #{@guest.lunch}"
        erb :edit_guest
      end
    end
  end


  get '/delete_guest' do
  redirect "/login" unless session[:user_id]
    @errors = []
    @submit_callback = "/delete_guest"
    puts "/delete_payment get"
    if !params[:id].nil?
      @guest = Guest.find(params[:id])
      puts "deleting guest: #{@guest.id}, #{@guest.name}"
      erb :delete_guest
    else
      puts "Unable to find guest id for delete #{params[:id]}"
      @on_complete_msg = "Unable to Delete Guest.  Guest not Found for id #{params[:id]}"
      @on_complete_redirect=  "/workshops"
      @on_complete_method=  "get"
      erb :done
    end
  end

  # add are you sure here.
  post '/delete_guest' do
  redirect "/login" unless session[:user_id]
    if params[:id]
      @guest = Guest.find(params[:id])
      if @guest
        workshop_id = @guest.workshop_id
        guest_name = @guest.name
        guest_id = @guest.id
        @guest.delete
        puts "/delete_guest called for id: #{guest_id} #{guest_name} workshop: #{workshop_id}"
        Log.new_entry "Guest deleted id: #{guest_id} #{guest_name} workshop: #{workshop_id}"
        redirect "/edit_workshop?id=#{workshop_id}"
      end
    end
  end


post '/save_guest' do
  @errors = []
  puts "/save_guest #{params}"
   if !params[:id].nil?
    @guest = Guest.find(params[:id])
    if @guest
      @guest.name = params[:name]
      @guest.email = params[:email]
      @guest.client_type = params[:client_type]
      @guest.lunch = params[:lunch]
      @guest.phone = params[:phone]
      @guest.notes = params[:notes]
      @guest.amount = params[:amount]

          
      if params[:paid]
        @guest.paid  = true
      else
        @guest.paid  = false
      end 
      if params[:follow_up_email]
        @guest.follow_up_email  = true
      else
        @guest.follow_up_email  = false
      end
      if params[:email_sent]
        @guest.email_sent  = true
      else
        @guest.email_sent  = false
      end
      if params[:follow_up_session]
        @guest.follow_up_session  = true
      else
        @guest.follow_up_session  = false
      end
      if params[:hw_complete]
        @guest.hw_complete  = true
      else
        @guest.hw_complete  = false
      end
      if params[:in_both]
        @guest.in_both  = true
      else
        @guest.in_both  = false
      end
      if params[:results_back]
        @guest.results_back  = true
      else
        @guest.results_back  = false
      end
      if params[:results_prepared]
        @guest.results_prepared  = true
      else
        @guest.results_prepared  = false
      end
      if params[:eli_released]
        @guest.eli_released  = true
      else
        @guest.eli_released  = false
      end
      Log.new_entry "Workshop attendee information changed for : #{@guest.id} #{@guest.name}"
      if @guest.save
        redirect "/edit_workshop?id=#{@guest.workshop_id}"
      else
        @on_complete_msg = "Unable to save Workshop Attendee Changes."
      end
    else 
      puts "guest not found id: #{params[:id]}"
      @on_complete_msg = "Workshop Attendee Not Found.  Unable to save changes."
    end
      @guest.workshop_id = params[:workshop_id]  
      @on_complete_redirect=  "/edit_workshop?id=#{@guest.workshop_id}"
      @on_complete_method=  "get"
      @param_name = "id"
      @param_value = @guest.workshop_id
      erb :done
  else
    puts "/save_guest params :id not found "
    @errors << "Guest Not Found"
    erb :edit_guest
  end
end


post '/save_new_guest' do
  @errors = []

  #read required parameters

  if params[:name]
    @name = params[:name]
  else
    @errors << "Please enter guest name."
  end
  if params[:email]
    @date = params[:email]
  else
    @errors << "Please enter guest email."
  end
  if params[:amount]
    @amount = params[:amount]
  else
    @errors << "Please enter guest amount."
  end
  if params[:workshop_id]
    @workshop_id = params[:workshop_id]
  else
    @errors << "Please enter workshop id."
  end 
  if params[:client_type]
    @paid = params[:client_type]
  else
    @errors << "Please enter client type."
  end
  if params[:phone]
    @phone = params[:phone]
  else
    @errors << "Please enter client phone."
  end

  # check required parameters
  if !@errors.empty?
    erb :new_guest 
  else
    @guest = Guest.new
    @guest.name = params[:name]
    @guest.email = params[:email]  
    @guest.phone = params[:phone]
    @guest.amount = params[:amount]
    @guest.client_type = params[:client_type]  
    @guest.workshop_id = params[:workshop_id]  
    @workshop = Workshop.find(@guest.workshop_id) 

    # get optional parameters and save

    if params[:paid]
      @guest.paid  = true
    else
      @guest.paid  = false
    end 
    if params[:follow_up_email]
      @guest.follow_up_email  = true
    else
      @guest.follow_up_email  = false
    end
    if params[:email_sent]
      @guest.email_sent  = true
    else
      @guest.email_sent  = false
    end
    if params[:follow_up_session]
      @guest.follow_up_session  = true
    else
      @guest.follow_up_session  = false
    end
    if params[:hw_complete]
      @guest.hw_complete  = true
    else
      @guest.hw_complete  = false
    end
    if params[:in_both]
      @guest.in_both  = true
    else
      @guest.in_both  = false
    end
    if params[:results_back]
      @guest.results_back  = true
    else
      @guest.results_back  = false
    end
    if params[:results_prepared]
      @guest.results_prepared  = true
    else
      @guest.results_prepared  = false
    end
    if params[:eli_released]
      @guest.eli_released  = true
    else
      @guest.eli_released  = false
    end
    if params[:lunch]
     @guest.lunch = params[:lunch]
   end 
    if params[:phone]
     @guest.phone = params[:phone]
   end 
    if params[:notes]
     @guest.notes = params[:notes]
   end
    puts "guest name #{@guest.name} date #{@guest.amount}"  
    if @guest.save
      Log.new_entry "Workshop attendee added: #{@workshop.name} Id: #{@guest.id} Name: #{@guest.name}"
      redirect "/edit_workshop?id=#{params[:workshop_id]}"
    else
      puts "Error saving new workshop attendee #{@guest.name}"
      @on_complete_msg = "Error Saving New Workshop Attendee."
      @on_complete_redirect=  "/edit_workshop?id=#{@guest.workshop_id}"
      @on_complete_method=  "get"
      @param_name = "id"
      @param_value = @guest.workshop_id
      erb :done
    end
  end
  #should not get here
  erb :done
end