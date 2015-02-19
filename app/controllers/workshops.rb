get '/workshops' do
  @workshops = Workshop.all
  erb :workshops  
end

get '/new_workshop' do
  @errors = []
  @callback_method = '/save_new_workshop'
  erb :new_workshop  
end


post '/save_new_workshop' do
  @errors = []

  #read params
  #create new worksho
  if params[:name]
    @name = params[:name]
  else
    @errors << "Please enter workshop name."
  end
  if params[:date]
    @date = params[:date]
  else
    @errors << "Please enter workshop date."
  end
  
   if !@errors.empty?
      erb :new_workshop 
    else
      @workshop = Workshop.new
      puts "workshop:  #{@workshop}"  
      @workshop.name = params[:name]
      @workshop.date = params[:date]  
      puts "Workshop name #{@workshop.name} date #{@workshop.date}"  
      @workshop.save
    end
end

  get '/edit_workshop' do
    @errors = []
    @callback_method = '/save_workshop'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id)
      if @workshop
        erb :edit_workshop
      end
    end
  end

  post '/save_workshop' do
    @errors = []
    puts "/save_workshop #{params}"
     if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      if @workshop
        @workshop.name = params[:name]
        @workshop.date = params[:date]
        @workshop.save
      else 
        puts "workshop not found id: #{params[:id]}"
      end
      puts "saving workshop changes"
      @on_complete_msg = "Workshop Changes Saved."
      @on_complete_redirect=  "/workshops"
      @on_complete_method=  "get"
      erb :done
    else
      puts "/save_workshop params :id not found "
      @errors << "Workshop Not Found"
      erb :edit_workshop
    end
  end


get '/new_guest' do
  puts "/new_guest called #{params}"
  @workshop_id = params[:workshop_id]
  @errors = []
  @callback_method = '/save_new_guest'
  erb :new_guest  
end


post '/save_guest' do
  @errors = []
  puts "/save_guest #{params}"
   if !params[:id].nil?
    @guest = Guest.find(params[:id])
    if @guest
      @guest.name = params[:name]
      @guest.email = params[:email]
      @guest.save
    else 
      puts "guest not found id: #{params[:id]}"
    end
    puts "saving guest changes"
    @on_complete_msg = "Guest Changes Saved."
    #find the right workshop and redirect there.
    @on_complete_redirect=  "/workshops"
    @on_complete_method=  "get"
    erb :done
  else
    puts "/save_guest params :id not found "
    @errors << "Guest Not Found"
    erb :edit_guest
  end
end


post '/save_new_guest' do
  @errors = []

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
  if params[:paid]
    @date = params[:paid]
  else
    @errors << "Please enter guest paid."
  end
  if params[:workshop_id]
    @workshop_id = params[:workshop_id]
  else
    @errors << "Please enter workshop id."
  end
  
  
  puts "/save_new_guest errors:  @errors.count"
   if !@errors.empty?
      erb :new_guest 
    else
      @guest = Guest.new
      puts "guest:  #{@guest}"  
      @guest.name = params[:name]
      @guest.email = params[:email] 
      @guest.amount = params[:amount] 
      @guest.paid = params[:paid]  
      @guest.workshop_id = params[:workshop_id]  
      puts "guest name #{@guest.name} date #{@guest.amount}"  
      @guest.save
    end

    puts "***** /edit_workshop?id=#{@guest.workshop_id}"
    @on_complete_msg = "New Workshop Attendee Saved."
    @on_complete_redirect=  "/edit_workshop?id=#{@guest.workshop_id}"
    @on_complete_method=  "get"
    @param_name = "id"
    @param_value = @guest.workshop_id

    puts "on complete:  #{ @on_complete_redirect}"
    erb :done
end


