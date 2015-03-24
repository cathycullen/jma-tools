


get '/new_workshop_expense' do
  redirect "/login" unless session[:user_id]
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
  redirect "/login" unless session[:user_id]
    client_types
    @errors = []
    @submit_callback = '/save_workshop_expense'
    begin 
    if !params[:id].nil?
      @workshop_expense = WorkshopExpense.find(params[:id])
      if @workshop_expense
        @workshop_id = @workshop_expense.workshop_id
        erb :edit_workshop_expense
      end
    end
    rescue Exception => e
      puts "excpetion #{e.message}"
    end
  end

  get '/delete_workshop_expense' do
  redirect "/login" unless session[:user_id]
    if params[:id]
      begin
        @workshop_expense = WorkshopExpense.find(params[:id])
        if @workshop_expense
          workshop_id = @workshop_expense.workshop_id
          @workshop_expense.delete
          redirect "/edit_workshop?id=#{workshop_id}"
        end
        rescue Exception => e
        puts "excpetion #{e.message}"
      end
    end
  end



