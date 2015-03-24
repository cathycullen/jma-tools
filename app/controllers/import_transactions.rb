get '/prompt_import_file' do
    redirect "/login" unless session[:user_id]
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

