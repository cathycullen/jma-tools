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
      
    
    def send_email(name, email, amount, category, appt_date, payment_date, appt_start, appt_end, coach, location,
      text1, text2, text3, text4, text5, interview_text1, interview_text2, interview_text3, template, payment_text, greeting,
      closing_text)
      @name = name
      @email = email
      @amount = amount
      @category = category
      @coach = coach
      @coach_name = coach.name
      @coach_email = coach.email
      @coach_phone = coach.phone
      @location = location
      @appt_date_formatted = appt_date
      @payment_date_formatted = payment_date
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
      @payment_text = payment_text
      @greeting = greeting
      @closing_text = closing_text

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
        puts "send_welcome_email coach #{coach.name} amount #{amount} date #{@appt_date_formatted} payment date #{@payment_date_formatted} start #{@appt_start} end #{@appt_end}"
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
    def send_pre_workshop_email(name, email, amount, appt_date, payment_date, appt_start, appt_end, location,
      text1, text2, text3, text4, text5, interview_text1, interview_text2, interview_text3, template, payment_text, greeting1, greeting2,
      closing_text)
      @name = name
      @email = email
      @amount = amount
      @location = location
      @appt_date_formatted = appt_date
      @payment_date_formatted = payment_date
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
      @payment_text = payment_text
      @greeting1 = greeting1
      @greeting2 = greeting2
      @closing_text = closing_text

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
        #need a list of recipient emails here
        @email = "cathy@softwareoptions.com"
        attachments['JMA_getting_results.pdf'] = File.read('public/images/JMA_Getting_Results.pdf')
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
    



    def send_perpetual_lens_email(name, email, amount, appt_date, payment_date, appt_start, appt_end, location,
      text1, text2, text3, text4, text5, interview_text1, interview_text2, interview_text3, template, payment_text, greeting,
      closing_text)
      @name = name
      @email = email
      @amount = amount
      @location = location
      @appt_date_formatted = appt_date
      @payment_date_formatted = payment_date
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
      @payment_text = payment_text
      @greeting = greeting
      @closing_text = closing_text

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
        #need a list of recipient emails here
        attachments['Perceptual Lens Assessment Instructions.pdf'] = File.read('public/images/Perceptual Lens Assessment Instructions.pdf')
        puts "sending perpetual lense email to #{@email}"
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
