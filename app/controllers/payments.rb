
require 'chartkick'

def payment_totals 

  @payments = Payment.filter_entries(@coach_filter, @category_filter, @transaction_filter, @start_date, @end_date)
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

  if !params[:start_date].nil?
    @start_date =  Date.strptime(params[:start_date], "%m/%d/%Y")
    @start_date_selected = params[:start_date]
  @end_date_selected = "End Date"
  end
  if !params[:end_date].nil?
    @end_date =  Date.strptime(params[:end_date], "%m/%d/%Y")
    @end_date_selected = params[:end_date]
  end
  puts "****************** start_date #{@start_date}   end_date #{@end_date}"



  payment_totals

  erb :payments
  end

  get '/payments2' do
    erb :payments2
  end

  get '/prompt_import_file' do
    erb :import_transactions
  end

  post '/import_transactions' do
  DATE ||=0
  NAME ||= 1
  AMOUNT ||= 4
  COACH ||=2
  CATEGORY ||=3
  TRANSACTION_TYPE ||=5

  puts "/import_transactions called"

  csv_text = params['myfile'][:tempfile].read
  csv = CSV.parse(csv_text, :headers=>true)
  
  begin
    csv.each  do |row|
      if row[DATE]
        excel_date = (row[DATE].gsub /"/, '')
        transaction_date = Date.strptime(excel_date, "%m/%d/%y %H:%M")
      end
      if row[NAME]  
        name = (row[NAME].gsub /"/, '').split(' ')
         if(name.size > 1)
            fullname = name.first + ' ' + name.last
          else 
            fullname = name.first
          end
      end

      amount = 0
      if row[AMOUNT] != nil then
        amount = row[AMOUNT].gsub(/['$]/, "").gsub(/"/, '')
      end
      if row[COACH]
        coach_name = row[COACH].gsub /"/, ''
        coach = Coach.find_by_name(coach_name)
      end
      if row[CATEGORY]
        category_name = (row[CATEGORY].gsub /"/, '')
        category = Category.find_by_name(category_name)
      end

      if row[TRANSACTION_TYPE]
        transaction_type = (row[TRANSACTION_TYPE].gsub /"/, '')
      end

      payment = Payment.new
      payment.populate(fullname, amount, coach, category)
      payment.payment_date = transaction_date
      payment.transaction_type = transaction_type
      payment.status = PAID
      payment.save
      puts "#{transaction_date} #{fullname}  #{amount} #{coach_name}  #{category.name} count: #{Payment.count} sum: #{Payment.sum('amount')}"
      if category.nil?
        puts "************ category is nil for #{fullname}"
      end
      if coach.nil?
        puts "************ coach is nil for #{fullname}"
      end

      #create client
      client = Client.find_by_name(fullname)
      if client.nil?
        puts "Client #{fullname} not found.  Create new client"
        client = Client.new
        client.name = fullname
        client.coach = coach
        client.category = category
        puts "Client created #{client.coach}, #{client.category}"
        
        client.save
      end
    end
    puts "Done collecting paymentS. #{Payment.count}"
    rescue Exception => e
      puts e.backtrace
      puts "rescue caught while reading payment entries from #{params['myfile'][:filename]} : #{e.message}"
    end
  end


  get '/prompt_weekly_payment' do
    erb :prompt_weekly_payment
  end

post '/weekly_payment_entries' do
  NAME ||= 2
  AMOUNT ||= 1
  COACH ||=5
  CATEGORY ||=3

  @pending_entries = []
  @invalid_entries = []
  puts "/weekly_payment_entries was called"

  #cleanup any previous payment attempts
  begin
    Payment.delete_invalid_entries
    Payment.delete_pending_entries
  rescue Exception => e
      puts e.backtrace
      puts "rescue caught deleting pending entries : #{e.message}"
    
  end

  csv_text = params['myfile'][:tempfile].read
  csv = CSV.parse(csv_text, :headers=>true)
  
  begin
    csv.each  do |row|
      amount = 0
      if row[AMOUNT] != nil then
        amount = row[AMOUNT].gsub(/['$]/, "").gsub(/"/, '')
      end
      if row[NAME] then 
        name = (row[NAME].downcase.gsub /"/, '').split.each{|i| i.capitalize!}.join(' ').split(' ')
        puts "name #{name}  class: #{name.class}"
        fullname = name[0] + ' '+ name[1]
        puts "fullname: #{fullname} "
      end
      if row[COACH]
        coach_name = (row[COACH].downcase.gsub /"/, '').split.each{|i| i.capitalize!}.join(' ')
        coach = Coach.find_by_name(coach_name)
      end
      if row[CATEGORY]
        category_name = (row[CATEGORY].gsub /"/, '')
        category = Category.find_by_name(category_name)
      end

      puts "name: #{fullname} amount: #{amount} coach #{coach.name} category #{category.name}"
      @payment = Payment.new
      @payment.populate(fullname, amount, coach, category)
      @payment.name = fullname
      @payment.transaction_type = CREDIT_CARD
      @payment.save
      puts "payment status #{@payment.status} count: #{Payment.count}"
    end

    puts "Done collecting payment entries. #{Payment.pending_entries.count}"
    puts "call pre_payment_summary count:  Payment.pending_entries.count"  
    erb :pre_payment_summary
    rescue Exception => e
      puts e.backtrace
      puts "rescue caught while reading payment entries from #{params['myfile'][:filename]} : #{e.message}"
    end
  end
   

  post '/process_weekly_payments' do
  completed = 0
     
  if params[:commit] == 'Submit'
    puts "Payment.valid_entries #{Payment.valid_entries}"
    puts "Payment.valid_entries.count #{Payment.valid_entries.count}"
    
    if (Payment.pending_entries != nil)
      puts "in /process_payments Payment.pending_entries #{Payment.pending_entries}"
      total_entries = Payment.valid_entries.count
      begin
        arrow_payment = ArrowPayment.new()
        
        Payment.pending_entries.each do |payment|
        if ((error_message = arrow_payment.submit_recurring_payment(
          payment[:name],
          payment[:amount],
          'API payment'
        )).nil?)
            payment[:status] = PAID
            completed = completed + 1
            @progress_value = (completed.to_f / total_entries) * 100
            puts "Progress value #{@progress_value}"
            
        else
          puts "******************error_message: #{error_message}"
          payment[:msg] = error_message
          payment[:status] = ERROR
        end
        payment.save
      end
      email = Mailer.send_jma_weekly_summary()
      email.deliver
      puts "call results summary"
      erb :weekly_results_summary
    
      rescue Exception => e
        puts "rescue caught in process_payments #{e.message}"
        @error_message = e.message
        puts e.backtrace
      end
      else
        puts "payment_entries is nil.  unable to process payments"
      end
    else
      #user hit cancel show upload screen again
      puts "User hit cancel "
      Payment.delete_invalid_entries
      erb :prompt_weekly_payment
    end
end
  
  

  post '/done_weekly_payments' do
    if params[:done] == 'Done'
      erb :prompt_weekly_payment
    end
  end


