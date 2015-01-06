require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/arrow_payment.db")

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize


class Payment
  include DataMapper::Resource
  attr_accessor :cc_number,
                :exp_month,
                :exp_year,
                :ccv,
                :errors

  property :id, Serial
  property :name, String
  property :email, String
  property :phone, String
  property :address, String
  property :city, String
  property :state, String
  property :zip, String
  property :amount, Float
  property :created_at, DateTime

  def initialize
    @errors = []
  end
  
  def self.jma_template_payment
    p = Payment.new 
    if ENV['RACK_ENV'] == 'development' then
      p.name='John Doe'
      p.email='john@johndoe.com'
      p.phone='7737849897'
      p.cc_number='4408 0412 3456 7893'
      p.exp_month='06'
      p.exp_year='2016'
      p.ccv='123'
      p.address='4860 N Hermitage St'
      p.city='Chicago'
      p.state='IL'
      p.zip='60640'
      p.amount=0
    end
    p
  end

  def valid?
    @errors = []

    # check each field for errors
    if @name.split(/\W+/).size < 2 then
      @errors << "Please Enter a Valid Name"
    end

    if @email.index("@").nil? || @email.index(".").nil? then
      @errors << "Please Enter a Valid Email Address"
    end

    if @phone.size < 10 then
      @errors << "Please Enter a Valid Telephone Number"
    end

    if @exp_month.length == 0 or @exp_month.to_i < 1 or @exp_month.to_i > 12 then
      @errors << "Please Enter a Valid Expiration Month"
    end

    if @exp_year.length == 0 or @exp_year.to_i < Time.new.year or @exp_year.to_i > (Time.new.year + 10) then
      @errors << "Please Enter a Valid Expiration Year"
    end

    # check expiration date has not passed
    if @exp_year.to_i == Time.new.year  && @exp_month.to_i < Time.new.month then
      @errors << "Credit Card is Expired"
    end

    if @ccv.length > 0 && @ccv.length != 3 then
      @errors << "Please Enter a Valid Credit Card Code"
    end

    if @address.length == 0 then
      @errors << "Please Enter Your Address"
    end

    if @city.length == 0 then
      @errors << "Please Enter Your City"
    end

    if @state.length != 2 then
      @errors << "Please Enter Your State"
    end

    if @zip.length != 5 then
      @errors << "Please Enter a Valid Zip Code"
    end

    #remove spaces and dashes from cc_number
    @cc_number.gsub(/([- ])/, '')
    credit_card = CreditCard.new(@cc_number.gsub(/([- ])/, ''))

    if !credit_card.valid? then
      @errors << "Please Enter a Valid Credit Card Number"
    end

    if credit_card.amex? then
      @errors << "Sorry We Do Not Accept American Express Cards.  Please Enter a Valid Credit Card."
    end

    @errors.empty?
  end
  
  
  def valid_email_form?
    @errors = []

    # check each field for errors
    if @name.split(/\W+/).size < 2 then
      @errors << "Please Enter a Valid Name"
    end
    
    if @email.index("@").nil? || @email.index(".").nil? then
      @errors << "Please Enter a Valid Email Address"
    end
    
    @errors.empty?
  end
end
