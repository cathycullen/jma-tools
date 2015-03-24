
get '/coaches' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @coaches = Coach.all.order('id')
  erb :coaches
end

get '/new_coach' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @submit_callback = "/save_new_coach"
  puts "submit_callback #{@submit_callback}"
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
        redirect "/coaches"
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
        redirect "/coaches"
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
  redirect "/login" unless session[:user_id]

    @errors = []
    puts "/delete_coach #{params}"
     if !params[:id].nil?
      @coach = Coach.find(params[:id])
      if @coach
        @coach_name = @coach.name
        if @coach.delete
          redirect "/coaches"
        else
          @on_complete_msg = "Error.  Unable to delete Coach."
        end
      else 
        @on_complete_msg =  "coach not found id: #{params[:id]}"
      end
    else
      puts "/delete_coach params :id not found "
      @on_complete_msg =   "No Coach Id provided. Coach not deleted."
      @on_complete_redirect=  "/coaches"
      @on_complete_method=  "get"
      erb :done
    end
  end


get '/edit_coach' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @submit_callback = '/save_coach'
  if !params[:id].nil?
    @coach = Coach.find(params[:id])
    if @coach
      erb :edit_coach
    end
  end
end

