get '/workshops' do
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
      @workshop.save
    end
end

