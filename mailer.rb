require 'action_mailer'
require 'date'
require './coach'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.view_paths= File.dirname(__FILE__)

  class Mailer < ActionMailer::Base
  
  
    def send_career_cheetah_email_confirm(name, amount, email)
      @name = name
      @amount = amount
      @email = email
      time = Time.new
      @date = Time.local(time.year, time.month, time.day) 
      @date = Time.now.strftime("%b %d, %Y")

           
    ActionMailer::Base.smtp_settings = {
      :address   => ENV['CAREER_CHEETAH_ADDRESS'],
      :port      => ENV['CAREER_CHEETAH_PORT'],
      :domain    => ENV['CAREER_CHEETAH_DOMAIN'],
      :authentication => :plain,
      :user_name      => ENV['CAREER_CHEETAH_USER'],
      :password       => ENV['CAREER_CHEETAH_PASS'],
      :enable_starttls_auto => true,
    }

      # add to_address to parameters and fudge for now.

      mail( 
        :to      =>  @email,
        :from    => ENV['CAREER_CHEETAH_FROM_ADDRESS'],
        :subject => "Thank You For Your Payment",
      ) do |format|
        format.html
        format.text
      end
    end

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
    
    
    def send_jma_email_payment_link(name, email, amount)
      @name = name
      @email = email
      @amount = amount
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
  
      retval = ""
      if(a_date != nil)
        date_arr = a_date.split(/\\|-/)
        rev_date = Date.parse("#{date_arr[1]}/#{date_arr[0]}/#{date_arr[2]}")
        puts "in formate_date a_date #{a_date}"
        puts "in formate_date rev_date #{rev_date}"
        retval = rev_date.strftime('%A, %B') + " " +rev_date.strftime('%d').to_i.to_s+ @end_str[rev_date.strftime('%d').to_i.to_s]
      end
      retval
    end
      
    def send_welcome_email(name, email, amount, appt_date, payment_date, coach_name, coach_email, coach_phone, location)
      @name = name
      @email = email
      @amount = amount
      @coach_name = coach_name
      @coach_email = coach_email
      @coach_phone = coach_phone
      @location = location
      
      if appt_date != nil 
        @appt_date_s = format_date(appt_date)
      end
      if payment_date != nil
        @payment_date_s = format_date(payment_date)
      end
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
      puts "send_welcome_email coach #{coach_name} amount #{amount} date #{@appt_date} payment date #{@payment_date}"
      mail( 
        :to      =>  @email,
        :from    => ENV['JMA_FROM_ADDRESS'],
        :subject => "Welcome To Jody Michael Associates",
      ) do |format|
        format.html
        format.text
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
end
