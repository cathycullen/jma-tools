require 'yaml'

configure do
end

helpers do
  puts "workshops helpers called"

  def client_types
    @client_types ||= YAML.load_file('client_types.yml')
  end
  
end


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
    if params[:name]
      @name = params[:name]
    else
      @errors << "Please enter workshop name."
    end
    if params[:date]
      @workshop_date = params[:date]
      puts "**************** workshop date class #{@workshop_date.class}"
    else
      @errors << "Please enter workshop date."
    end
   if !@errors.empty?
      erb :new_workshop 
    else
      @workshop = Workshop.new 
      @workshop.name = @name
      @workshop.workshop_date = Date.strptime(@workshop_date, "%m/%d/%Y") 
      
      if @workshop.save!
        @on_complete_msg = "Workshop Added."
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
        @workshop.workshop_date = Date.strptime(params[:date], "%m/%d/%Y")
        if @workshop.save
          @on_complete_msg = "Workshop Added."
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
    @callback_method = '/save_workshop'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id)
      @workshop_expenses = WorkshopExpense.where(:workshop_id => @workshop.id)
      if @workshop
        erb :edit_workshop
      end
    end
  end

  get '/delete_workshop' do
    @errors = []
    @callback_method = '/delete_workshop'
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
    @callback_method = '/workshops'
    if !params[:id].nil?
      @workshop = Workshop.find(params[:id])
      @attendees = Guest.where(:workshop_id => @workshop.id)
      if @attendees
        erb :workshop_lunch_report2
      end
    end
  end

  get '/workshop_report' do
    @errors = []
    @callback_method = '/workshops'
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

  @workshop_id = params[:workshop_id]
  @errors = []
  @callback_method = '/save_new_guest'
  erb :new_guest  
end

  get '/edit_guest' do
    client_types
    @errors = []
    @callback_method = '/save_guest'
    if !params[:id].nil?
        @guest = Guest.find(params[:id])
      if @guest
        erb :edit_guest
      end
    end
  end

  get '/delete_guest' do
    if params[:id]
      @guest = Guest.find(params[:id])
      if @guest
        workshop_id = @guest.workshop_id
        @guest.delete
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
      @guest.paid = params[:paid]
      @guest.client_type = params[:client_type]
      @guest.lunch = params[:lunch]
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

      puts "on complete:  #{ @on_complete_redirect}"
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
    @paid = params[:paid]
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


get '/new_workshop_expense' do
  puts "/new_workshop_expense called #{params}"
  @workshop_id = params[:workshop_id]
  @errors = []
  @callback_method = '/save_new_workshop_expense'
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
      @workshop_expense.save
    else 
      puts "workshop_expense not found id: #{params[:id]}"
    end
    puts "saving workshop_expense changes"
    @on_complete_msg = "WorkshopExpense  Saved."
    #find the right workshop and redirect there.
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



