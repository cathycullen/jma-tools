require 'action_mailer'
require 'date'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.view_paths= File.dirname(__FILE__)

  class Mailer < ActionMailer::Base
  
    def send_jma_email_confirm(name, amount, email)
      @name = name
      @amount = amount
      @email =  email
      time = Time.new
      @date = Time.local(time.year, time.month, time.day) 
      @date = Time.now.strftime("%b %d, %Y")
    
      ActionMailer::Base.smtp_settings = {
        :address   => ENV['JMA_ADDRESS'],
        :port      => ENV['JMA_PORT'],
        :domain    => ENV['JMA_DOMAIN'],
        :authentication => :"login",
        :user_name      => ENV['JMA_USER'],
        :password       => ENV['JMA_PASS'],
        :enable_starttls_auto => true,
      }
      
      puts "sending confirm to client at this address:  #{@email} from: #{ENV['JMA_FROM_ADDRESS']}"
      mail( 
        :to      =>  @email,
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "Thank You From Jody Michael Associates",
      ) do |format|
        format.html
        format.text
      end
    end
    
    
    def send_jma_email_payment_link(name, email, amount, category, coach)
      @name = name
      @email = email
      @amount = amount
      @category = category
      @coach = coach
      puts "send_jma_email_payment_link amount #{amount}"
      time = Time.new
      @date = Time.local(time.year, time.month, time.day) 
      @date = Time.now.strftime("%b %d, %Y")
    
      ActionMailer::Base.smtp_settings = {
        :address   => ENV['JMA_ADDRESS'],
        :port      => ENV['JMA_PORT'],
        :domain    => ENV['JMA_DOMAIN'],
        :authentication => :"login",
        :user_name      => ENV['JMA_USER'],
        :password       => ENV['JMA_PASS'],
        :enable_starttls_auto => true,
      }
      mail( 
        :to      =>  @email,
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "Welcome To Jody Michael Associates",
      ) do |format|
        format.html
        format.text
      end
    end
      
    def format_date(a_date)
    @end_str = {'1' => 'st', '2' => 'nd', '3' => 'rd', '4' =>'th', '5' =>'th', '6' => "th", '7' => "th", '8' => "th", '9' => "th", '0' => "th" }
    puts "datepicker #{a_date}"
      retval = ""
      if(a_date != nil)
        #date_arr = a_date.split(/\\|-/)
        date_arr = a_date.split("/")
        if date_arr[0] != nil && date_arr[1] != nil && date_arr[2] != nil then
          rev_date = Date.parse("#{date_arr[1]}/#{date_arr[0]}/#{date_arr[2]}")
           puts "in formate_date  a_date #{a_date} rev_date #{rev_date}"
          #retval = rev_date.strftime('%A, %B') + " " +rev_date.strftime('%d').to_i.to_s+ @end_str[rev_date.strftime('%d').to_i.to_s[-1,1]]
          retval = rev_date.strftime('%A, %B') + " " +rev_date.strftime('%d').to_i.to_s
        else
          puts "invalid date #{a_date}  date_arr #{date_arr}"
        end
      end
      retval
    end
    
    def send_welcome_email(name, email, amount, category, appt_date, payment_date, appt_start, appt_end, coach, location)
      @name = name
      @email = email
      @amount = amount
      @category = category
      @coach = coach
      @coach_name = coach.name
      @coach_email = coach.email
      @coach_phone = coach.phone
      @location = location
      @appt_date_s = ''
      @payment_date_s = ''

      begin
        if appt_date != nil 
          #@appt_date_s = format_date(appt_date)
          @appt_date_s = appt_date
        end
        if payment_date != nil
          #@payment_date_s = format_date(payment_date)
          @payment_date_s = payment_date
        end
        @appt_start = appt_start
        @appt_end = appt_end
        time = Time.new
        @date = Time.local(time.year, time.month, time.day) 
        @date = Time.now.strftime("%b %d, %Y")
        
        ActionMailer::Base.smtp_settings = {
          :address   => ENV['JMA_ADDRESS'],
          :port      => ENV['JMA_PORT'],
          :domain    => ENV['JMA_DOMAIN'],
          :authentication => :"login",
          :user_name      => ENV['JMA_USER'],
          :password       => ENV['JMA_PASS'],
          :enable_starttls_auto => true,
        }
        puts "send_welcome_email coach #{coach.name} amount #{amount} date #{@appt_date} payment date #{@payment_date} start #{@appt_start} end #{@appt_end}"
        mail( 
          :to      =>  @email,
          :from    => ENV['JMA_FROM_ADDRESS'],
          :subject => "Welcome To Jody Michael Associates",
        ) do |format|
          format.html
          format.text
        end
      rescue Exception => e
        puts "rescue caught in send_welcome_email #{e.message}"
        @error_message = e.message
        puts e.backtrace 
      end
    end
    
    def send_email(name, email, amount, category, appt_date, payment_date, appt_start, appt_end, coach, location,
      text1, text2, text3, text4, text5, interview_text1, interview_text2, interview_text3, template)
      @name = name
      @email = email
      @amount = amount
      @category = category
      @coach = coach
      @coach_name = coach.name
      @coach_email = coach.email
      @coach_phone = coach.phone
      @location = location
      @appt_date = appt_date
      @payment_date = payment_date
      @appt_start = appt_start
      @appt_end = appt_end
      @text1 = text1
      @text2 = text2
      @text3 = text3
      @text4 = text4
      @text5 = text5
      @interview_text1 = interview_text1
      @interview_text2 = interview_text2
      @interview_text3 = interview_text3
      @template = template

      begin
        time = Time.new
        @date = Time.local(time.year, time.month, time.day) 
        @date = Time.now.strftime("%b %d, %Y")
        
        ActionMailer::Base.smtp_settings = {
          :address   => ENV['JMA_ADDRESS'],
          :port      => ENV['JMA_PORT'],
          :domain    => ENV['JMA_DOMAIN'],
          :authentication => :"login",
          :user_name      => ENV['JMA_USER'],
          :password       => ENV['JMA_PASS'],
          :enable_starttls_auto => true,
        }
        puts "send_welcome_email coach #{coach.name} amount #{amount} date #{@appt_date} payment date #{@payment_date} start #{@appt_start} end #{@appt_end}"
        mail( 
          :to      =>  @email,
          :from    => ENV['JMA_FROM_ADDRESS'],
          :subject => "Welcome To Jody Michael Associates",
        ) do |format|
          format.html
          format.text
        end
      rescue Exception => e
        puts "rescue caught in send_welcome_email #{e.message}"
        @error_message = e.message
        puts e.backtrace 
      end
    end

    def send_interview_email(name, email, amount, appt_date, payment_date, appt_start, appt_end, coach, category, location)
      @name = name
      @email = email
      @amount = amount
      @coach = coach
      @coach_name = coach.name
      @coach_email = coach.email
      @coach_phone = coach.phone
      @location = location
      @category = category
      @appt_date_s = ''
      @payment_date_s = ''
      
      begin
        if appt_date != nil 
          @appt_date_s = format_date(appt_date)
        end
        if payment_date != nil
          @payment_date_s = format_date(payment_date)
        end
        @appt_start = appt_start
        @appt_end = appt_end
        time = Time.new
        @date = Time.local(time.year, time.month, time.day) 
        @date = Time.now.strftime("%b %d, %Y")
        
        puts "start time #{@appt_start} end time #{@appt_end}"
      
        ActionMailer::Base.smtp_settings = {
          :address   => ENV['JMA_ADDRESS'],
          :port      => ENV['JMA_PORT'],
          :domain    => ENV['JMA_DOMAIN'],
          :authentication => :"login",
          :user_name      => ENV['JMA_USER'],
          :password       => ENV['JMA_PASS'],
          :enable_starttls_auto => true,
        }
        puts "send_interview_email coach #{@coach.name} amount #{amount} date #{@appt_date} payment date #{@payment_date} start #{@appt_start} end #{@appt_end}"
        mail( 
          :to      =>  @email,
          :from    => ENV['JMA_FROM_ADDRESS'],
          :subject => "Welcome To Jody Michael Associates",
        ) do |format|
          format.html
          format.text
        end
      rescue Exception => e
        puts "rescue caught in send_interview_email #{e.message}"
        @error_message = e.message
        puts e.backtrace 
      end
    end
    
    
    
    def credit_card_charged_email_to_jma_support(name, amount)
      @name = name
      @amount = amount
      time = Time.new
      @date = Time.local(time.year, time.month, time.day) 
      @date = Time.now.strftime("%b %d, %Y")
    
      ActionMailer::Base.smtp_settings = {
        :address   => ENV['JMA_ADDRESS'],
        :port      => ENV['JMA_PORT'],
        :domain    => ENV['JMA_DOMAIN'],
        :authentication => :"login",
        :user_name      => ENV['JMA_USER'],
        :password       => ENV['JMA_PASS'],
        :enable_starttls_auto => true,
      }
      mail( 
        :to      => ENV['JMA_SUPPORT_EMAIL'],
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "JMA Payment Received",
      ) do |format|
        format.html
        format.text
      end
    end
    
    
    def credit_card_info_received_to_jma_support(name, amount)
      @name = name
      @amount = amount
    
      ActionMailer::Base.smtp_settings = {
        :address   => ENV['JMA_ADDRESS'],
        :port      => ENV['JMA_PORT'],
        :domain    => ENV['JMA_DOMAIN'],
        :authentication => :"login",
        :user_name      => ENV['JMA_USER'],
        :password       => ENV['JMA_PASS'],
        :enable_starttls_auto => true,
      }
      puts "sending confirm to jma support team at this address:  #{ENV['JMA_SUPPORT_EMAIL']} from: #{ENV['JMA_FROM_ADDRESS']}"
      mail( 
        :to      => ENV['JMA_SUPPORT_EMAIL'],
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "JMA Payment Information Received",
      ) do |format|
        format.html
        format.text
      end
    end
    
    
    
     def submit_test_email(name, amount)
      @name = name
      @amount = amount
      time = Time.new
      @date = Time.local(time.year, time.month, time.day) 
      @date = Time.now.strftime("%b %d, %Y")
    
      begin
       ActionMailer::Base.smtp_settings = {
        :address   => ENV['JMA_ADDRESS'],
        :port      => ENV['JMA_PORT'],
        :domain    => ENV['JMA_DOMAIN'],
        :authentication => :"login",
        :user_name      => ENV['JMA_USER'],
        :password       => ENV['JMA_PASS'],
        :enable_starttls_auto => true,
      }
      puts "settings #{ActionMailer::Base.smtp_settings}"
      mail( 
        :to      => ENV['DEVELOPER_EMAIL'],
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "Thank You For Your Payment",
      ) do |format|
        format.html
        format.text
      end
      
       rescue Exception => e
      puts "rescue caught submit_test_email #{e.message}"
      puts e.backtrace
    end
    
    end
    
  def get_email (email)   
    retval = email
    if ENV['RACK_ENV'] == 'development' then
      retval = ENV['DEVELOPER_EMAIL']
    end
    puts "get_email retval #{retval}"
    retval
  end

  def send_jma_weekly_summary()
    
    begin    
      @date = Time.now.strftime("%b %d, %Y")
        
      ActionMailer::Base.smtp_settings = {
        :address   => ENV['JMA_ADDRESS'],
        :port      => ENV['JMA_PORT'],
        :domain    => ENV['JMA_DOMAIN'],
        :authentication => :"login",
        :user_name      => ENV['JMA_USER'],
        :password       => ENV['JMA_PASS'],
        :enable_starttls_auto => true,
      }

      mail( 
       # :to      => ENV['DEVELOPER_EMAIL'] + ", jody@jodymichael.com, kelly@jodymichael.com",
        :to      => ENV['DEVELOPER_EMAIL'],
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "JMA Weekly Payment Processing Summary",
      ) do |format|
        format.html
        format.text
      end
      
      rescue Exception => e
          puts "rescue caught in send_jma_weekly_summary #{e.message}"
          @error_message = e.message
          puts e.backtrace
      end
    end
end
