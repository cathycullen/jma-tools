$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sinatra'
require 'dotenv'
require 'json'
require 'data_mapper'
require 'yaml'
require './cc_date_helper'
#require './initialize'
include CCDateHelper
require 'chronic'

configure do
end

helpers do
  def categories
    puts "is nil categories? #{@categories.nil?}"
    @categories ||= Category.all
  end

  def coaches
    @coaches ||= Coach.all
  end

  def url_root
    if ENV['RACK_ENV'] == 'development' then
      @url_root = "localhost:9393"
    else
      @url_root = "https://"+APP_NAME+".herokuapp.com"
    end
  end
end

def new_format_date(a_date)
  rev_date = Chronic.parse(a_date)
  retval = rev_date.strftime('%A, %B') + " " +rev_date.strftime('%d').to_i.to_s
end

def get_params(params)
  puts "get_params params:  #{params}, how many  #{params.count}"

  @text1 = params[:text1]
  @text2 = params[:text2]
  @text3 = params[:text3]
  @text4 = params[:text4]
  @text5 = params[:text5]
  @closing_text = params[:closing_text]
  @name = params[:name]
  @email = params[:email]
  @appt_date = params[:appt_date]
  @appt_date_formatted = new_format_date(@appt_date)
  @payment_date = params[:payment_date]
  @payment_date_formatted = new_format_date(@appt_date)
  @appt_start = params[:appt_start]
  @appt_end = params[:appt_end]
  @category_name = params[:category]
  @coach_name = params[:coach_name]
  @location = params[:location]
  @coach_id = params[:coach_id]
  @category_id = params[:category_id]
  @send_callback_method = params[:send_callback_method]
  @interview_text1 = params[:interview_text1]
  @interview_text2 = params[:interview_text2]
  @interview_text3 = params[:interview_text3]
  @template = params[:template]
  @payment_text = params[:payment_text]
  puts "@payment_date_formatted:  #{@payment_date_formatted}"
  puts "@payment_date:  #{@payment_date}"

  if params[:amount].size > 0
    @amount=params[:amount].to_f
  else 
    @amount = 0
  end
  if !@coach_name.nil?  && @coach_name.size
    @coach = Coach.find_by_name(@coach_name)
  end

  if !@category_name.nil?  && @category_name.size
    @category = Category.find_by_name(@category_name)
  end

  if !@coach_id.nil?
    @coach = Coach.find(@coach_id)
  end
  if !@category_id.nil?
    @category = Category.find(@category_id)
  end
  if @coach.nil?
    @errors << "Please Enter Coach Name"
  end

  if @category.nil?
    @errors << "Please Enter Category Name"
  end

end

def show_param_results
  puts "#{@name}"
  puts "#{@email}"
  puts "#{@appt_date}"
  puts "#{@appt_date_formatted}"
  puts "#{@payment_date}"
  puts "#{@payment_date_formatted}"
  puts "#{@amount}"
  puts "#{@appt_start}"
  puts "#{@appt_end}"
  puts "#{@coach.name}"
  puts "#{@category.name}"
  puts "#{@location}"
  puts "#{@text1}"
  puts "interview_text1: #{@interview_text1}"
  puts "#{@template}"
end

def populate_template
  @errors = []
  @preview_callback_method = "/preview"
  @send_callback_method = "/send"
  @interview_text1 = ""
  @interview_text2 = ""
  @interview_text3 = ""
  @text1 = "Welcome to Jody Michael Associates. We are delighted to have the opportunity to work with you. You are scheduled for the below appointment(s)."
  @text2 = "*If we have not received your payment information in the timeframe above, we will release your time slot. "
  @text3 = "Office locations and phone session procedures (please keep this information to reference for future sessions):"
  @text4 = "Please sign in with the building's concierge and take the elevators up to the 26th floor. Please let yourself in and have a seat in the waiting area.

Parking is available for JMA clients - pull all the way up the circle drive and ask the concierge for the Jody Michael Associates garage keys. The parking instructions are in the black leather pouch. If the keys are not available, the client in the time slot before you may have parked – you can wait for the keys and may need to cut into your session time 5-10 minutes to park."
  @text5 = "Please note that this is a residential building with two main entrances. Please let yourself in the door at the top of the stairs and have a seat in the waiting area.

This is also the location of JMA's career exploration center. You will receive more information if this applies to your coaching process.

Free street parking is available most times. If you need a temporary permit, please let us know when you arrive."
  @closing_text = "We look forward to working with you."
  @payment_text = " enter your credit card information "
end

def populate_interview_template
  @interview_text1 = "Please send me a copy of your résumé along with the job title(s) and a brief description of the job you are targeting (optional)"
  @interview_text2 = "This session will include a mock interview, as well as time for feedback and coaching around your performance. This will mock an initial, general interview which will include questions it is highly probable you will be asked on a first interview.

We can't guarantee that the questions you will be asked in your mock interview will be asked in an actual interview, but they are intended to hit the points in an interview."

  @interview_text3 = "Your coach will not break character as interviewer, nor should you as interview candidate until the interview portion of the session is complete. Treat this like the real thing!

Feedback from your coach will be constructive, but direct in nature. If you feel you are thin-skinned or sensitive to negative feedback you should:"
end


get '/pay_per_session_email_template' do
  #populate default text for email template and show template
  populate_template
  @template = "pay_per_session"
  erb :email_template
end

get '/fixed_fee_email_template' do
  #populate default text for email template and show template
  populate_template
  @template = "fixed_fee"
  @payment_text = " submit your payment "
  erb :email_template
end

get '/interview_email_template' do
  #populate default text for email template and show template
  populate_template
  populate_interview_template
  @template = "interview"
  puts "@template:  #{@template}"
  erb :email_template
end

post '/preview' do
  puts "@payment_date_formatted:  #{@payment_date_formatted}"
  # read user parameters, display preview of email
 
  @errors = []
  get_params(params)
  erb :preview
end

post '/send' do
  #read user parameters and send formatted email
  get_params(params)
  show_param_results

  email = Mailer.send_email(
    @name,
    @email,
    @amount,
    @category,
    @appt_date_formatted,
    @payment_date_formatted,
    @appt_start,
    @appt_end,
    @coach,
    @location,
    @text1,
    @text2,
    @text3,
    @text4,
    @text5,
    @interview_text1,
    @interview_text2,
    @interview_text3,
    @template,
    @payment_text
  )
  email.deliver
  #redirect to some thank you page
  erb :welcome_email_sent
end


