
get '/prompt_weekly_payment' do
  erb :prompt_weekly_payment
end

post '/weekly_payment_entries' do
  NAME ||= 2
  AMOUNT ||= 1
  COACH ||=4
  CATEGORY ||=3

  @pending_entries = []
  @invalid_entries = []
  @payment_errors = []
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
        if coach.nil?
          puts "Please Enter a Valid Coach for #{fullname}"
          @payment_errors << "Please Enter a Valid Coach for #{fullname}"
        end
      end
      if row[CATEGORY]
        category_name = (row[CATEGORY].gsub /"/, '')
        category = Category.find_by_name(category_name)
        if category.nil?
          puts "Please Enter a Valid Coach for #{fullname}"
          @payment_errors << "Please Enter a Valid category for #{fullname}"
        end
      end
      if (!coach.nil? && !category.nil?)
        puts "name: #{fullname} amount: #{amount} coach #{coach.name} category #{category.name}"
        @payment = Payment.new
        @payment.populate(fullname, amount, coach, category)
        @payment.name = fullname
        @payment.transaction_type = CREDIT_CARD
        @payment.save
        puts "payment status #{@payment.status} count: #{Payment.count}"
      end
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


