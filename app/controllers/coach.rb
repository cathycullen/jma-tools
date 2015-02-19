
get '/coaches' do
  @errors = []
  @coaches = Coach.all
  erb :coaches
end

get '/new_coach' do
  @errors = []
  @submit_callback = "/save_new_coach"
  erb :add_coach
end

post '/save_new_coach' do
  if params[:commit] == 'Submit'
    @coach_name = params[:name]
    @coach = Coach.find_by_name(@coach_name)
    puts "is coach nil #{@coach.nil?}"
    if @coach.nil?
      @coach = Coach.new
      @coach.name = @coach_name
      @coach.phone = params[:phone]
      @coach.email = params[:email]
      retval = @coach.save
      if retval
        puts "retval from save:  #{retval}"
        puts "coach #{@coach.name} added"
        @on_complete_msg = "Coach #{@coach_name} has been added."
        @on_complete_redirect=  "/coaches"
        @on_complete_method=  "get"
        puts "on_complete_msg #{@on_complete_msg}"
        erb :done
      else
        puts "Add Coach returned and error and was not saved"
        @on_complete_msg = "Add Coach returned and error and was not saved"
      end
  else
      puts "Coach already exists #{@coach.name}"
      @on_complete_msg = "Coach already exists #{@coach.name}"
    end
  end
  @on_complete_redirect=  "/coaches"
  @on_complete_method=  "get"
  erb :done
end


post '/save_coach' do
  if params[:commit] == 'Submit'
    @coach_id = params[:id]
    puts "@coach_id #{@coach_id}"
    @coach = Coach.find(@coach_id)
    if !@coach.nil?
      @coach_name = params[:name]
      @coach.name = @coach_name
      retval = @coach.save
      if retval
        puts "retval from save:  #{retval}"
        puts "coach #{@coach.name} saved"
        @on_complete_msg = "Coach #{@coach_name} has been saved."
        @on_complete_redirect=  "/categories"
        @on_complete_method=  "get"
        erb :done
      else
        puts "Save Coach returned and error and was not saved"
        @on_complete_msg = "Save Coach returned and error and was not saved"
      end
  else
      puts "Coach id does not exist #{@coach.id}"
      @on_complete_msg = "Coach id does not exist #{@coach.id} and could not be saved"
    end
  end
  @on_complete_redirect=  "/categories"
  @on_complete_method=  "get"
  erb :done
end

get '/delete_coach' do

  @errors = []
  puts "/save_coach #{params}"
   if !params[:id].nil?
    @coach = Coach.find(params[:id])
    if @coach
      @coach_name = @coach.name
      @coach.delete
    else 
      puts "coach not found id: #{params[:id]}"
    end
    puts "delete coach"
    @on_complete_msg = "Coach #{@coach_name} has been removed."
    @on_complete_redirect=  "/coaches"
    @on_complete_method=  "get"
    erb :done
  else
    puts "/delete_coach params :id not found "
    @errors << "Coach Not Found"
    erb :coaches
  end
end


get '/edit_coach' do
  @errors = []
  @callback_method = '/save_coach'
  if !params[:id].nil?
    @coach = Coach.find(params[:id])
    if @coach
      erb :edit_coach
    end
  end
end

