require 'yaml'

configure do
end

helpers do
  def client_types
    @client_types ||= YAML.load_file('client_types.yml')
  end
  
end


get '/workshops' do
  redirect "/login" unless session[:user_id]
  @workshops = Workshop.all.order('id')
  erb :workshops  
end

get '/new_workshop' do
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
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
  


