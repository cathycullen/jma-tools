require 'yaml'

configure do
end

helpers do
  def client_types
    @client_types ||= YAML.load_file('client_types.yml')
  end
  
end


get '/workshops' do
  @workshops = Workshop.all.order('id')
  erb :workshops  
end

get '/new_workshop' do
  @errors = []
  @submit_callback = '/save_new_workshop'
  erb :new_workshop 
end


  post '/save_new_workshop' do
    @errors = []
    if params[:name]
      @name = params[:name]
    else
      @errors << "Please enter workshop name."
    end
    if params[:date]
      @workshop_date = params[:date]
    else
      @errors << "Please enter workshop date."
    end

    if params[:workshop_type]
      @workshop_type = params[:workshop_type]
    end
   if !@errors.empty?
      erb :new_workshop 
    else
      @workshop = Workshop.new 
      @workshop.name = @name
      @workshop.workshop_type = @workshop_type
      @workshop.workshop_date = Date.strptime(@workshop_date, "%m/%d/%Y") 
      
      if @workshop.save!
        Log.new_entry "New workshop added: #{@workshop.name} Date: #{@workshop.workshop_date}"
  
        redirect "/workshops"
      else
        @on_complete_msg = "New Workshp returned and error and was not saved"
      end
      @on_complete_redirect=  "/workshops"
      @on_complete_method=  "get"
      erb :done
    end
  end

  post '/save_workshop' do
    @errors = []
    puts "/save_workshop #{params}"
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      if @workshop
        @workshop.name = params[:name]

        @workshop.workshop_type = params[:workshop_type]
        @workshop.workshop_date = Date.strptime(params[:date], "%m/%d/%Y")
        if @workshop.save
          Log.new_entry "Workshop saved: #{@workshop.name} Date: #{@workshop.workshop_date} Type: #{@workshop.workshop_type}"
          redirect "/workshops"
        else
          @on_complete_msg = "Save Workshp returned and error and was not saved"
        end
      else 
        @on_complete_msg = "workshop not found id: #{params[:id]}"
      end
      @on_complete_redirect=  "/workshops"
      @on_complete_method=  "get"
      erb :done
    end
  end


  get '/edit_workshop' do
    @errors = []
    @submit_callback = '/save_workshop'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id).order('id')
      @workshop_expenses = WorkshopExpense.where(:workshop_id => @workshop.id).order('id')
      if @workshop
        erb :edit_workshop
      end
    end
  end

  get '/delete_workshop' do
    @errors = []
    @submit_callback = '/delete_workshop'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      if @workshop
        erb :delete_workshop
      end
    end
  end


  post '/delete_workshop' do
    puts "/delete_workshop post called"
    @errors = []
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      Log.new_entry "Workshop deleted: #{@workshop.name} Date: #{@workshop.workshop_date}"
      @workshop.delete

      puts "Workshop Was Deleted {@workshop.id}"
      @on_complete_msg = "Workshop Was Deleted"
    else
      puts "Unable to Delete Workshop.  Workshop not Found for id #{params[:id]}"
      @on_complete_msg = "Unable to Delete Workshop.  Workshop not Found for id #{params[:id]}"
    end
    @on_complete_redirect=  "/workshops"
    @on_complete_method=  "get"
    erb :done
  end


  get '/workshop_lunch_report' do
    @errors = []
    @submit_callback = '/workshops'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id)
      if @attendees
        erb :workshop_lunch_report2
      end
    end
  end


  get '/workshop_notes' do
    @errors = []
    @submit_callback = '/workshops'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id)
      if @attendees
        erb :workshop_notes
      end
    end
  end

  get '/workshop_report' do
    @errors = []
    @submit_callback = '/workshops'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id)
      @expenses = WorkshopExpense.where(:workshop_id => @workshop.id)
      if @attendees
        erb :workshop_report
      end
    end
  end
  

get '/new_guest' do
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


get '/new_workshop_expense' do
  puts "/new_workshop_expense called #{params}"
  @workshop_id = params[:workshop_id]
  @errors = []
  @submit_callback = '/save_new_workshop_expense'
  erb :new_workshop_expense  
end


post '/save_workshop_expense' do
  @errors = []
  puts "/save_workshop_expense #{params}"
   if !params[:id].nil?
    @workshop_expense = WorkshopExpense.find(params[:id])
    if @workshop_expense
      @workshop_expense.description = params[:description]
      @workshop_expense.amount = params[:amount]
      if @workshop_expense.save
        redirect "/edit_workshop?id=#{@workshop_expense.workshop_id}"
      else
        puts "Error saving workshop_expense changes"
        @on_complete_msg = "Error saving workshop_expense changes."
      end
    else 
        @on_complete_msg = "Error saving workshop_expense changes."
    end
    @on_complete_redirect=  "/workshops"
    @on_complete_method=  "get"
    erb :done
  else
    puts "/save_workshop_expense params :id not found "
    @errors << "WorkshopExpense Not Found"
    erb :edit_workshop_expense
  end
end


post '/save_new_workshop_expense' do
  @errors = []

  if params[:description]
    @description = params[:description]
  else
    @errors << "Please enter workshop_expense description."
  end
  
  if params[:amount]
    @amount = params[:amount]
  else
    @errors << "Please enter workshop_expense amount."
  end
  if params[:workshop_id]
    @workshop_id = params[:workshop_id]
  else
    @errors << "Please enter workshop id."
  end
  
  puts "/save_new_workshop_expense errors:  @errors.count"
   if !@errors.empty?
      erb :new_workshop_expense 
    else
      @workshop_expense = WorkshopExpense.new
      puts "workshop_expense:  #{@workshop_expense}"  
      @workshop_expense.description = params[:description]
      @workshop_expense.amount = params[:amount] 
      @workshop_expense.workshop_id = params[:workshop_id]  
      puts "workshop_expense name #{@workshop_expense.description} date #{@workshop_expense.amount}"  
      @workshop_expense.save
    end

    redirect "/edit_workshop?id=#{params[:workshop_id]}"
  end

  get '/edit_workshop_expense' do
    client_types
    @errors = []
    @submit_callback = '/save_workshop_expense'
    if !params[:id].nil?
      @workshop_expense = WorkshopExpense.find(params[:id])
      if @workshop_expense
        @workshop_id = @workshop_expense.workshop_id
        erb :edit_workshop_expense
      end
    end
  end

  get '/delete_workshop_expense' do
    if params[:id]
      @workshop_expense = WorkshopExpense.find(params[:id])
      if @workshop_expense
        workshop_id = @workshop_expense.workshop_id
        @workshop_expense.delete
        redirect "/edit_workshop?id=#{workshop_id}"
      end
    end
  end



