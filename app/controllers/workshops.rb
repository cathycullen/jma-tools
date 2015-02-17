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



