 get '/hab_codes' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @hab_codes = HabCode.all.order('id')
  @hab_codes = HabCode.get_assigned()
  @unassigned_hab_codes = HabCode.get_unassigned()
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
      @hab_code.debriefed = params[:debriefed]
      @hab_code.report_sent = params[:report_sent]

      if !params[:date_sent].nil?
        @hab_code.date_sent = DateTime.strptime(params[:date_sent], '%m/%d/%Y')  
        puts "Date sent:  #{params[:date_sent]}  #{@hab_code.date_sent.to_date}"
      end
      if @hab_date_sent.nil?
        @hab_code.assigned = true
      end
      if !params[:completed].nil?
        @hab_code.completed = DateTime.strptime(params[:completed], '%m/%d/%Y')  
        puts "Completed:  #{params[:completed]}  #{@hab_code.completed.to_date}"
      end
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
      @hab_code.debriefed = params[:debriefed]
      @hab_code.report_sent = params[:report_sent]

      if !params[:date_sent].nil?
        @hab_code.date_sent = DateTime.strptime(params[:date_sent], '%m/%d/%Y')  
        puts "Date sent:  #{params[:date_sent]}  #{@hab_code.date_sent.to_date}"
      end
      if !params[:completed].nil?
        @hab_code.completed = DateTime.strptime(params[:completed], '%m/%d/%Y')  
        puts "Completed:  #{params[:completed]}  #{@hab_code.completed.to_date}"
      end
      if @hab_date_sent.nil?
        @hab_code.assigned = true
      end
      @hab_code.coach_id = params[:coach_id]
      retval = @hab_code.save
      if retval
        redirect "/hab_codes"
      else
        puts "Save Hab returned and error and was not saved"
        @on_complete_msg = "Save Hab returned and error and was not saved"
      end
    else
        puts "Hab id does not exist #{@hab.id}"
        @on_complete_msg = "Hab id does not exist #{@hab.id} and could not be saved"
      end
  end
  @on_complete_redirect=  "/hab_codes"
  @on_complete_method=  "get"
  erb :done
end


get '/old_delete_hab_code' do
  redirect "/login" unless session[:user_id]

    @errors = []
    puts "/delete_hab #{params}"
     if !params[:id].nil?
      @hab_code = HabCode.find(params[:id])
      if @hab_code
        if @hab_code.delete
          redirect "/hab_codes"
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


  get '/delete_hab_code' do
  redirect "/login" unless session[:user_id]
    @errors = []
    @submit_callback = "/delete_hab_code"
    puts "/delete_hab_code get"
    if !params[:id].nil?
      @hab_code = HabCode.find(params[:id])
      puts "deleting hab_code for #{@hab_code.code}, #{@hab_code.first_name}, #{@hab_code.last_name}"
      erb :delete_hab_code
    else
      puts "Unable to find hab_code id for delete #{params[:id]}"
      @on_complete_msg = "Unable to Delete Hab Code.  hab code not Found for id #{params[:id]}"
      @on_complete_redirect=  "/hab_codes"
      @on_complete_method=  "get"
      erb :done
    end
  end


  post '/delete_hab_code' do
  redirect "/login" unless session[:user_id]
    puts "/hab_code post called"
    @errors = []
    if !params[:id].nil?
      @hab_code = HabCode.find(params[:id])
      puts "deleting hab_code for #{@hab_code.code}, #{@hab_code.first_name}, #{@hab_code.last_name}"
      Log.new_entry "Hab Code deleted #{@hab_code.code }, #{@hab_code.first_name}, $#{@hab_code.last_name}, #{Date.today}"
      @hab_code.delete

      puts "HabCode Was Deleted {@hab_code.id}"
      @on_complete_msg = "Hab Code Was Deleted"
    else
      puts "Unable to Delete Hab Code.  Hab Code not Found for id #{params[:id]}"
      @on_complete_msg = "Unable to Delete Hab Code.  Hab Code not Found for id #{params[:id]}"
    end
    @on_complete_redirect=  "/hab_codes"
    @on_complete_method=  "get"
    erb :done
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


get '/import_hab_codes' do
    erb :import_hab_codes
  end

post '/import_hab_codes' do
  CODE ||= 0

  puts "/import_hab_codes was called"

  csv_text = params['myfile'][:tempfile].read
  csv = CSV.parse(csv_text, :headers=>true)
   
  begin
    csv.each  do |row|
      amount = 0
      if row[CODE] != nil then
        code = row[CODE].gsub(/['$]/, "").gsub(/"/, '')
        puts "read code #{code}"
      else
        puts "row[CODE] blank "
      end
      if !code.nil? 
        puts "code: #{code} "
        @hab_code = HabCode.new
        @hab_code.code = code
        if @hab_date_sent.nil?
          @hab_code.assigned = true
        end
        @hab_code.save
        puts "hab_code #{@hab_code.code}"
      end
    end

    puts "Done importing codes" 
    
    @on_complete_redirect=  "/hab_codes"
    @on_complete_method=  "get"
    erb :done
    rescue Exception => e
      puts e.backtrace
      puts "rescue caught while reading hab codes from #{params['myfile'][:filename]} : #{e.message}"
    end
  end


get '/initialize_hab_codes' do
    erb :import_hab_codes
  end


post '/initialize_hab_codes' do
  COACH ||= 0
  CODE ||= 1
  LAST_NAME ||= 2
  FIRST_NAME ||= 3
  DATE_SENT ||= 4
  REGISTERED ||= 5
  COMPLETED ||= 6
  DEBRIEFED ||= 7
  REPORT_SENT ||= 8

  puts "/initialize_hab_codes was called"
  puts "params #{params}"

  csv_text = params['myfile'][:tempfile].read
  csv = CSV.parse(csv_text, :headers=>true)
   
  begin
    csv.each  do |row|

      puts "row 0 #{row[0]}"
      puts "row 1 #{row[1]}"
      puts "row 2 #{row[2]}"
      puts "row 3 #{row[3]}"
      puts "row 4 #{row[4]}"
      puts "row 5 #{row[5]}"
      puts "row 6 #{row[6]}"
      puts "row 7 #{row[7]}"
      puts "row 8 #{row[8]}"

      if row[CODE] != nil then
        code = row[CODE].gsub(/['$]/, "").gsub(/"/, '')
        if !code.nil? 
          puts "code: #{code} "
          @hab_code = HabCode.new
          @hab_code.code = code
        end
      end
      if row[COACH] != nil then
        coach_name = row[COACH].gsub(/['$]/, "").gsub(/"/, '')
        puts "coach name:  #{coach_name}"
        if !coach_name.nil?
          coach = Coach.find_by_name(coach_name)
          puts "coach #{coach}  name:  #{coach.name} email: #{coach.email}"
          @hab_code.coach_id = coach.id
        end
      end
      if row[LAST_NAME] != nil then
        last_name = row[LAST_NAME].gsub(/['$]/, "").gsub(/"/, '')
        if !last_name.nil?
          @hab_code.last_name = last_name
        end
      end
      if row[FIRST_NAME] != nil then
        first_name = row[FIRST_NAME].gsub(/['$]/, "").gsub(/"/, '')
        if !first_name.nil?
          @hab_code.first_name = first_name
        end
      end
      if row[DATE_SENT] != nil then
        date_sent = row[DATE_SENT].gsub(/['$]/, "").gsub(/"/, '')
        if !date_sent.nil?
          @hab_code.date_sent =  Date::strptime(date_sent, "%m/%d/%Y")
        end
      end
      puts "Is date_sent nil?  #{@hab_code.date_sent.nil?}  #{@hab_code.date_sent}"
      if row[REGISTERED] != nil then
        registered = row[REGISTERED].gsub(/['$]/, "").gsub(/"/, '')
        puts "registered #{registered}"
        if !registered.nil?
          if registered == "x"
            registered = true
          else
            registered = false
          end
          @hab_code.registered = registered
        end
      else 
        puts "registered is nil"
      end
      if row[COMPLETED] != nil then
        completed = row[COMPLETED].gsub(/['$]/, "").gsub(/"/, '')
        puts "completed #{completed}"
        if !completed.nil?
          @hab_code.completed = Date::strptime(completed, "%m/%d/%Y")
        end
      end
      if row[DEBRIEFED] != nil then
        debriefed = row[DEBRIEFED].gsub(/['$]/, "").gsub(/"/, '')
        if !debriefed.nil?
          if debriefed == "x"
            debriefed = true
          else
            debriefed = false
          end
          @hab_code.debriefed = debriefed
        end
      end

      puts "ROW report_sent  #{row[REPORT_SENT]} #{row[8]}"
      if row[REPORT_SENT] != nil then
        report_sent = row[REPORT_SENT].gsub(/['$]/, "").gsub(/"/, '')
        if !report_sent.nil?
          if report_sent == "x"
            report_sent = true
          else
            report_sent = false
          end
          @hab_code.report_sent = report_sent
          puts "report_sent #{report_sent}   #{row[REPORT_SENT]}"
        end
      end


      if !code.nil? 
        if @hab_code.date_sent.nil?
          @hab_code.assigned = false
          puts "assigned"
        else
          @hab_code.assigned = true
        end
        @hab_code.save
        puts "hab_code #{@hab_code.code}  assigned? #{@hab_code.assigned}"
      end
    end

    puts "Done importing codes" 
    
    @on_complete_redirect=  "/hab_codes"
    @on_complete_method=  "get"
    erb :done
    rescue Exception => e
      puts e.backtrace
      puts "rescue caught while reading hab codes from #{params['myfile'][:filename]} : #{e.message}"
    end
  end
   
