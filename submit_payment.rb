$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sinatra'
require 'dotenv'
require 'json'
require 'data_mapper'
require 'yaml'
require './payment'
require './arrow_payment'
require './credit_card'
require './mailer'
require './cc_date_helper'
require './initialize'
require './coach'
include CCDateHelper
#include CoachHelper


    @@coaches = []
    puts "initialize submit payment"
    yml = YAML.load_file("coach.yml") 
    yml.each do |k|
      puts "coach #{k['coach']} #{k['email']} #{k['phone']}"
      coach = Coach.new(k['coach'], 
      k['email'], 
      k['phone'])
      @@coaches << coach
    end

  def get_coach_by_name(name)
    if @@coaches.nil?
      puts "@coaches is nil"
    else puts "@coaches size #{@@coaches.count}"
    end
    
    retval = nil
    
    @@coaches.each do |coach|
      if coach.name == name
        retval = coach
        puts "get_coach_by_name found match #{name}"
      end
    end
    retval
  end
  
# automatically create the payment table
Payment.auto_upgrade!

get '/' do
    erb :send_jma_payment_form, :layout => :jma_min_layout
end


get '/send_client_welcome_email' do
    erb :send_client_welcome_email, :layout => :jma_min_layout
end

get '/send_payment_email' do
    erb :send_jma_payment_form, :layout => :jma_min_layout
end

post '/send_payment_email' do
  # send payment form.   read parameters, generate html, and send email.
  puts "/send_payment_email called params:  #{params}"
  @payment = Payment.new
  @payment.name=params[:name]
  @payment.email=params[:email]
  if params[:amount].size > 0
    @payment.amount=params[:amount]
  else 
    @payment.amount = 0
  end
  
  email = Mailer.send_jma_email_payment_link(
  @payment.name,
  @payment.email,
  @payment.amount
  )
  email.deliver
  #redirect to some thank you page
  erb :payment_email_sent, :layout => :jma_min_layout
end

 def format_date(a_date)
    @end_str = {'1' => 'st', '2' => 'nd', '3' => 'rd', '4' =>'th', '5' =>'th', '6' => "th", '7' => "th", '8' => "th", '9' => "th", '0' => "th" }
  
      retval = ""
      if(a_date != nil)
        date_arr = a_date.split(/\\|-/)
        rev_date = Date.parse("#{date_arr[1]}/#{date_arr[0]}/#{date_arr[2]}")
        retval = rev_date.strftime('%A, %B') + " " +rev_date.strftime('%d').to_i.to_s+ @end_str[rev_date.strftime('%d').to_i.to_s]
      end
      retval
    end
    
post '/show_send_welcome_email_format' do
 # send payment form.   read parameters, generate html, and send email.
  puts "post /test_format params #{params}"
  @name=params[:name]
  @email=params[:email]
  if params[:amount].size > 0
    @amount=params[:amount].to_f
  else 
    @amount = 0
  end
  @appt_date = params[:appt_date]
  @appt_date_s = format_date(@appt_date)
  @payment_date = params[:payment_date]
  @payment_date_s = format_date(@payment_date)
  
  puts "call test_send_welcome_email @amount #{@amount}"
  erb :test_send_welcome_email, :layout => :jma_min_layout
end

post '/send_welcome_email' do
  # send payment form.   read parameters, generate html, and send email.
  puts "post /send_welcome_email params #{params}"
  @payment = Payment.new
  @payment.name=params[:name]
  @payment.email=params[:email]
  if params[:amount].size > 0
    @payment.amount=params[:amount]
  else 
    @payment.amount = 0
  end
  
  @appt_date = params[:appt_date]
  @payment_date = params[:payment_date]
  coach_name = params[:coach]
  puts "coach name #{coach_name}"
  @location = params[:location]
  
  puts "call get_coach_by_name"
  @coach = get_coach_by_name(coach_name)
  puts "I found the coach #{@coach.name}"
    
  email = Mailer.send_welcome_email(
  @payment.name,
  @payment.email,
  @payment.amount,
  @appt_date,
  @payment_date,
  @coach.name,
  @coach.email,
  @coach.phone,
  @location
  )
  email.deliver
  #redirect to some thank you page
  erb :welcome_email_sent, :layout => :jma_min_layout
end


get '/career_cheetah_payment_form' do

  #fill in default values for testing
  @payment = Payment.cheetah_template_payment
  @submit_callback = '/career_cheetah_submit_payment'
  erb :payment_form, :layout => :cheetah_layout
end

post '/career_cheetah_submit_payment' do
  @payment = Payment.new
  @payment.name=params[:name]
  @payment.email=params[:email]
  @payment.phone=params[:phone]
  @payment.cc_number=params[:cc_number]
  @payment.exp_month= params[:cc_month]
  @payment.exp_year=params[:cc_year]
  @payment.ccv=params[:ccv]
  @payment.address=params[:address]
  @payment.city=params[:city]
  @payment.state= params[:state]
  @payment.zip=params[:zip]
  @payment.amount=params[:amount]

  if !@payment.valid?
    @submit_callback = '/career_cheetah_submit_payment'
    erb :payment_form, :layout => :cheetah_layout
  else
    description='Career Cheetah Payment'
    arrow_payment = ArrowPayment.new()
    payment_error = arrow_payment.submit_online_payment(
      @payment,
      description
    )

    if payment_error.nil?
      puts "Payment submitted successfully for #{@payment.name} amount: #{@payment.amount} "
      
      @payment.created_at = Time.now
      @payment.save!

      # send confirmation email to the credit card client
      print "$ " + @payment.amount.to_s
      email = Mailer.send_career_cheetah_email_confirm(
        @payment.name,
        "$ " + @payment.amount.to_s,
        @payment.email
       )
      email.deliver
      
       # send email to jma staff
      print "$ " + @payment.amount.to_s
      email = Mailer.credit_card_charged_email_to_jma_support(
        @payment.name,
        "$ " + @payment.amount.to_s,
        @payment.email
       )
      email.deliver

      redirect to("http://www.careercheetah.net/signup-thank-you")
    else
      @payment.errors = [payment_error]
      erb :payment_form
    end
  end
end
                                     
get '/jma_payment_form' do
   puts "params #{params} amount: #{params[:amount]}"
  #fill in default values for testing
  @payment = Payment.jma_template_payment
  @submit_callback = '/jma_submit_payment'
  if  params[:amount] != nil
    @payment.amount = params[:amount] 
  else @payment.amount = 0
  end
  puts "/jma_payment_form amount #{@payment.amount}"
  erb :payment_form, :layout => :jma_layout
end

post '/jma_submit_payment' do
  
  @payment = Payment.new
  @payment.name=params[:name]
  @payment.email=params[:email]
  @payment.phone=params[:phone]
  @payment.cc_number=params[:cc_number]
  @payment.exp_month= params[:cc_month]
  @payment.exp_year=params[:cc_year]
  @payment.ccv=params[:ccv]
  @payment.address=params[:address]
  @payment.city=params[:city]
  @payment.state= params[:state]
  @payment.zip=params[:zip]
  if params[:amount] != nil 
    @payment.amount=params[:amount]
  else 
    @payment.amount=0
  end

   if !@payment.valid?
    @submit_callback = '/jma_submit_payment'
    erb :payment_form, :layout => :jma_layout
  else
   

    description='Jody Michael Associates'
    arrow_payment = ArrowPayment.new()
    payment_error = arrow_payment.submit_online_payment(
      @payment,
      description
    )

    if payment_error.nil?
      puts "Payment info submitted successfully for #{@payment.name} amount: #{@payment.amount} "
      # send confirmation email
      email = Mailer.send_jma_email_confirm(
      @payment.name,
      @payment.amount,
      @payment.email
      )
      email.deliver
      @payment.created_at = Time.now
      @payment.save!
      
      
       # send email to jma staff      print "$ " + @payment.amount.to_s
      
      #email = Mailer.credit_card_charged_email_to_jma_support(
      #  @payment.name,
      #  "$ " + @payment.amount.to_s,
      #  @payment.email
      # )
      #OR
      email = Mailer.credit_card_info_received_to_jma_support(
        @payment.name,
        @payment.amount,
       )
       puts "call deliver from credit_card_info_received"
      email.deliver
      
      if @payment.amount > 0
        redirect to("http://www.jodymichael.com/payment-processed-thank-you")
      else
        redirect to("http://www.jodymichael.com/payment-info-thank-you")
      end
    else
      @payment.errors = [payment_error]
      erb :payment_form
    end
  end
end

  post '/done' do
  puts "/done called done:  #{params[:done]}   params: #{params}"
    if params[:done] == 'Continue'
      erb :send_jma_payment_form, :layout => :jma_min_layout
    end
  end
  
  

get '/submit_test_email' do
 erb :submit_test_email, :layout => :jma_layout
end

post '/submit_test_email' do
  email = Mailer.submit_test_email(
      "Henri Cullen",
      "$ 1000"
     )
    email.deliver
  erb :submit_test_email, :layout => :jma_layout
end

def production
  puts "production?  called "
  ENV['RACK_ENV'] == 'production'
end

def development
  puts "development?  called "
  ENV['RACK_ENV'] == 'development'
end


