require 'chartkick'

def payment_totals 
  @payments = Payment.filter_entries(@name_search, @coach_filter, @category_filter, @transaction_filter, @start_date, @end_date)
  @client_groups = Payment.group_by_clients
  @payment_sum = @payments.sum('amount')
  @sum_this_week = Payment.format_money(Payment.sum_this_week(@name_search, @coach_filter, @category_filter, @transaction_filter))
  @sum_this_month = Payment.format_money(Payment.sum_this_month(@name_search, @coach_filter, @category_filter, @transaction_filter))
  @sum_this_year = Payment.format_money(Payment.sum_this_year(@name_search, @coach_filter, @category_filter, @transaction_filter))
  @sum_today = Payment.format_money(Payment.sum_today(@name_search, @coach_filter, @category_filter, @transaction_filter))
  @category_chart = Payment.category_group_names(@coach_filter, @category_filter, @transaction_filter)
end

get '/password' do
  @errors = []
  @submit_callback = "/password"
  erb :password
end

post '/password' do
  if params[:password] == 'Makena'
    redirect to('/payments')
  else
    redirect to('/password')
  end
end


get '/payments' do
  #@payments = Payment.all_paid_entries
  @name_search = nil 
  @submit_callback = "/filter_payments"
  
    @coach_filter= map_all(Coach)
    @category_filter = map_all(Category)
    @transaction_filter = [CREDIT_CARD, CHECK]

    @coach_selected = 'All'
    @category_selected = 'All'
    @transaction_selected = 'All'
    @start_date_selected = ""
    @end_date_selected = ""
    @save_search = ""

    @save_params = {"category"=>["All"], "coach"=>["All"], "transaction"=>["All"]} 
    @category_selected = @save_params["category"]
    @coach_selected = @save_params["coach"]
    @transaction_selected = @save_params["transaction"]
    if params[:search]
      @payments = Payment.where("name like '%#{params[:search]}%'")
      @name_search = params[:search]
    end
    payment_totals
    puts "**** @payments count #{@payments.size}  is it true?   #{@payments != nil && @payments.size > 0 }"

    @payments.each do |payment|
      puts "payment: id: #{payment.id}  name: #{payment.name}"
    end
  erb :payments2
end

def map_all(obj)
  obj.all.map { |c| c } 
end

post '/filter_payments' do

  @save_params = params
  @category_selected = @save_params["category"].first
  @coach_selected = @save_params["coach"].first
  @transaction_selected = @save_params["transaction"].first


  if params[:coach].first == "All"
    @coach_filter= map_all(Coach)
  else
    @coach_filter = params[:coach]
  end

  if params[:category].first == "All"
    @category_filter = map_all(Category)
  else
    @category_filter = params[:category]
  end

  if params[:transaction].first == "All"
    @transaction_filter = [CREDIT_CARD, CHECK]
  else
    @transaction_filter = params[:transaction]
  end

  if !params[:start_date].nil? && params[:start_date].length > 0
    puts "start date #{params[:start_date]} nil? #{params[:start_date]}  length: #{params[:start_date].length}}"
    @start_date =  Date.strptime(params[:start_date], "%m/%d/%Y")
    @start_date_selected = params[:start_date]
  @end_date_selected = "End Date"
  end
  if !params[:end_date].nil? && params[:start_date].length > 0
    @end_date =  Date.strptime(params[:end_date], "%m/%d/%Y")
    @end_date_selected = params[:end_date]
  end
  
  payment_totals

  erb :payments2
  end

  get '/edit_payment' do
    @errors = []
    if !params[:payment_id].nil?
      @payment = Payment.find(params[:payment_id])
      @payment_id = params[:payment_id]
    end
    erb :edit_payment
  end


  post '/save_payment' do
    @errors = []
    
    if !params[:payment_id].nil?
      @payment_id = params[:payment_id]
      @payment = Payment.find(@payment_id)
      if @payment
        if params[:name].nil? then
         @errors << "Please Enter Payee Name"
        end
        if params[:amount].nil? then
         @errors << "Please Enter Payee Amount"
        end

        if !@errors.empty?
          erb :edit_payment
        else
          @payment.name = params[:name]
          @payment.amount = params[:amount]
          @payment.category_id = params[:category_id]
          @payment.coach_id = params[:coach_id]

          puts "payment:  #{@payment}"
          puts "transaction type #{@payment.transaction_type}, #{@payment.payment_date}, #{@payment.amount}, #{@payment.name}, #{@payment.coach_id}, "
          Log.new_entry "Payment saved #{@payment.payment_date.strftime("%m/%d/%Y") }, #{@payment.name}, $#{@payment.amount}, #{Date.today}"
        @payment.save
        end
      end
    end

    puts "params #{params[:payment_id]}, #{params[:name]}"
    @on_complete_msg = "Payment Information Saaved."
    @on_complete_redirect=  "/payments"
    @on_complete_method=  "get"
    erb :done
  end

  get '/delete_payment' do
    @errors = []
    @submit_callback = "/delete_payment"
    puts "/delete_payment get"
    if !params[:payment_id].nil?
      @payment = Payment.find(params[:payment_id])
      puts "deleting payment for #{@payment.payment_date}, #{@payment.name}, #{@payment.amount}, #{Date.today}"
      erb :delete_payment
    else
      puts "Unable to find payment id for delete #{params[:payment_id]}"
      @on_complete_msg = "Unable to Delete Payment.  Payment not Found for id #{params[:payment_id]}"
      @on_complete_redirect=  "/payments"
      @on_complete_method=  "get"
      erb :done
    end
  end

  post '/delete_payment' do
    puts "/delete_payment post called"
    @errors = []
    if !params[:payment_id].nil?
      @payment = Payment.find(params[:payment_id])
      puts "deleting payment for #{@payment.payment_date}, #{@payment.name}, #{@payment.amount}, #{Date.today}"
      Log.new_entry "Payment deleted #{@payment.payment_date.strftime("%m/%d/%Y") }, #{@payment.name}, $#{@payment.amount}, #{Date.today}"
      @payment.delete

      puts "Payment Was Deleted {@payment.id}"
      @on_complete_msg = "Payment Was Deleted"
    else
      puts "Unable to Delete Payment.  Payment not Found for id #{params[:payment_id]}"
      @on_complete_msg = "Unable to Delete Payment.  Payment not Found for id #{params[:payment_id]}"
    end
    @on_complete_redirect=  "/payments"
    @on_complete_method=  "get"
    erb :done
  end


