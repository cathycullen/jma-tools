get '/prompt_weekly_payment' do
    erb :prompt_weekly_payment
  end

post '/weekly_payment_entries' do
  NAME ||= 2
  AMOUNT ||= 1
  COACH ||=3
  CATEGORY ||=4

  @pending_entries = []
  @invalid_entries = []
  puts "/new_payment_entries was called"

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
        name = (row[NAME].gsub /"/, '').split(' ')
        fullname = name[0] + ' ' + name[1]
        puts "name: #{fullname} amount: #{amount} "
      end
      if row[COACH]
        coach_name = row[COACH]
        coach = Coach.find_by_name(coach_name)
      end
      if row[CATEGORY]
        category = row[CATEGORY]
      end
        @payment = Payment.new
        @payment.populate(fullname, amount, coach, category)
        @payment.name = fullname
        @payment.save
    end

    puts "Done collecting payment entries. #{Payment.pending_entries.count}"
    puts "call pre_payment_summary"  
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