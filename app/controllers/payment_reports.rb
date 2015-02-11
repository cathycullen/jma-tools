require 'chartkick'

def payment_totals 
  @payments = Payment.filter_entries(@coach_filter, @category_filter, @transaction_filter, @start_date, @end_date)
  @client_groups = Payment.group_by_clients
  @payment_sum = @payments.sum('amount')
  @sum_this_week = Payment.format_money(Payment.sum_this_week(@coach_filter, @category_filter, @transaction_filter))
  @sum_this_month = Payment.format_money(Payment.sum_this_month(@coach_filter, @category_filter, @transaction_filter))
  @sum_this_year = Payment.format_money(Payment.sum_this_year(@coach_filter, @category_filter, @transaction_filter))
  @sum_today = Payment.format_money(Payment.sum_today(@coach_filter, @category_filter, @transaction_filter))
  @category_chart = Payment.category_group_names(@coach_filter, @category_filter, @transaction_filter)
end


get '/payments' do
  #@payments = Payment.all_paid_entries
  @coach_filter= map_all(Coach)
  @category_filter = map_all(Category)
  @transaction_filter = [CREDIT_CARD, CHECK]

  @coach_selected = 'All'
  @category_selected = 'All'
  @transaction_selected = 'All'
  @start_date_selected = ""
  @end_date_selected = ""

  @save_params = {"category"=>["All"], "coach"=>["All"], "transaction"=>["All"]} 
  @category_selected = @save_params["category"]
  @coach_selected = @save_params["coach"]
  @transaction_selected = @save_params["transaction"]
  payment_totals
    
  erb :payments
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

  erb :payments
  end