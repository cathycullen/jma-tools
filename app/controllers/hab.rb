get '/hab_codes' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @hab_codes = HabCode.all.order('id')
  puts "hab code coach #{@hab_codes.first.coach_id}"
  erb :hab_codes
end


get '/new_hab_code' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @coaches = coaches
  puts "@coaches #{@coaches}"
  @submit_callback = "/save_new_hab_code"
  erb :add_hab_code
end


post '/save_new_hab_code' do
  if params[:commit] == 'Submit'
    @code = params[:code]

    #@coach_id = params[:coach]
    #if !@coach_id.nil?
    #  coach = Coach.find(@coach.id)
    #end

    @hab_code = HabCode.find_by_code(@code)
    puts "is hab_code nil #{@hab_code.nil?}"
    if @hab_code.nil?
      @hab_code = HabCode.new
      @hab_code.code = @code
      @hab_code.email = params[:email]
      @hab_code.last_name = params[:last_name]
      @hab_code.first_name = params[:first_name]
      @hab_code.registered = params[:registered]
      @hab_code.completed = params[:completed]
      @hab_code.debriefed = params[:debriefed]
      @hab_code.report_sent = params[:report_sent]
      @hab_code.coach_id = params[:coach_id]
      retval = @hab_code.save
      if retval
        redirect "/hab_codes"
      else
        puts "Add Hab Code returned and error and was not saved"
        @on_complete_msg = "Add ab Code returned and error and was not saved"
      end
    else
      puts "Hab Code  already exists #{@hab.code}"
      @on_complete_msg = "Hab Code already exists #{@hab.code}"
    end
  end
  @on_complete_redirect=  "/hab_codes"
  @on_complete_method=  "get"
  erb :done
end


post '/save_hab' do
  if params[:commit] == 'Submit'
    @hab_id = params[:id]
    puts "@hab_id #{@hab_id}"
    @hab_code = HabCode.find(@hab_id)
    if !@hab_code.nil?
      @code = params[:code]
      @hab_code.email = params[:email]
      @hab_code.last_name = params[:last_name]
      @hab_code.first_name = params[:first_name]
      @hab_code.registered = params[:registered]
      @hab_code.completed = params[:completed]
      @hab_code.debriefed = params[:debriefed]
      @hab_code.report_sent = params[:report_sent]
      @hab_code.coach_id = params[:coach_id]
      retval = @hab_code.save
      if retval
        redirect "/habs"
      else
        puts "Save Hab returned and error and was not saved"
        @on_complete_msg = "Save Hab returned and error and was not saved"
      end
    else
        puts "Hab id does not exist #{@hab.id}"
        @on_complete_msg = "Hab id does not exist #{@hab.id} and could not be saved"
      end
  end
  @on_complete_redirect=  "/habs"
  @on_complete_method=  "get"
  erb :done
end


get '/delete_hab_code' do
  redirect "/login" unless session[:user_id]

    @errors = []
    puts "/delete_hab #{params}"
     if !params[:id].nil?
      @hab_code = HabCode.find(params[:id])
      if @hab_code
        if @hab_code.delete
          redirect "/habs"
        else
          @on_complete_msg = "Error.  Unable to delete hab."
        end
      else 
        @on_complete_msg =  "hab not found id: #{params[:id]}"
      end
    else
      puts "/delete_hab params :id not found "
      @on_complete_msg =   "No hab Id provided. hab not deleted."
      @on_complete_redirect=  "/hab_codes"
      @on_complete_method=  "get"
      erb :done
    end
  end


get '/edit_hab_code' do
  redirect "/login" unless session[:user_id]
  @errors = []

  @coaches = coaches

  @submit_callback = '/save_hab'
  if !params[:id].nil?
    @hab_code = HabCode.find(params[:id])
    if @hab_code
      erb :edit_hab_code
    end
  end
end


