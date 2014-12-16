require 'arrow_payments'
require './payment'

class ArrowPayment

  def initialize()
    begin
      puts "initialize called"
      @arrow = app_config()
      @error_message = nil
      @payment_method = nil
      @customers = @arrow.customers
      puts "initialize done"
    rescue Exception => e
      puts "ArrowPayment:  rescue caught in initialize #{e.message}"
      puts e.backtrace 
    end
  end


  def app_config()

    ArrowPayments::Client.new(
      :api_key     => ENV['ARROW_API_KEY'],
      :mode        => ENV['ARROW_MODE'],
      :merchant_id => ENV['ARROW_MERCHANT_ID']
    )
  end

def submit_new_client_payment(payment, description)

    name_arr = payment.name.split(/\W+/)
    first = name_arr.first.downcase
    last = name_arr.last.downcase
    code = payment.name

    begin 
    # create client and payment_method
      puts "Create New Customer #{payment.name}"

      client = @arrow.create_customer(  
        :name => payment.name,
        :contact => payment.name,
        :code => code
      )
      puts "Create New PaymentMethod For Client #{payment.name}"
  
      create_payment_method_for_client( 
        client, 
        first, 
        last, 
        payment.cc_number, 
        payment.ccv, 
        payment.exp_month, 
        payment.exp_year, 
        payment.address, 
        payment.city, 
        payment.state, 
        payment.zip
      )

      # at this point if payment_method is nil then there was an error creating it.
      if @payment_method then

        # Create a new transaction for an existing customer and payment method.
        # Returns a new Transaction instance if request was successful, otherwise
        # raises ArrowPayments::Error exception with error message.
        if payment.amount > 0 then 
          begin
            transaction = @arrow.create_transaction(  
              :customer_id        => client.id, 
              :payment_method_id  => @payment_method.id,
              :transaction_type   => 'sale',
              :total_amount       => payment.amount,
              :tax_amount         => 0,
              :shipping_amount    => 0,
              :description        => description
            )
          rescue Exception => e
            puts "Exception caught in submit_online_payment @arrow.create_transaction #{e.message}"
            @error_message = e.message
          end
        end
      else
        puts "transaction could not be completed because no valid payment method exists"
      end
    rescue Exception => e
      puts "rescue caught in submit_online_payment #{e.message}"
      @error_message = e.message
      puts e.backtrace 
    end
    @error_message
  end
    
  def submit_online_payment(payment, description)

    puts "submit_online_payment called"
    name_arr = payment.name.split(/\W+/)
    first = name_arr.first.downcase
    last = name_arr.last.downcase
    code = payment.name

    client = get_client_by_name(first, last)
    
    begin 
      # if no client then create client and payment_method
      if !client then
        puts "Create New Customer #{payment.name}"

        client = @arrow.create_customer(  
          :name => payment.name,
          :contact => payment.name,
          :code => code
        )
        puts "Create New PaymentMethod For Client #{payment.name}"
    
        create_payment_method_for_client( 
          client, 
          first, 
          last, 
          payment.cc_number, 
          payment.ccv, 
          payment.exp_month, 
          payment.exp_year, 
          payment.address, 
          payment.city, 
          payment.state, 
          payment.zip
        )
      else
        puts "Customer Already Exists #{payment.name} id #{client.id}"
        # need to retrieve payment method for client
        @payment_method = (client.payment_methods.find_all {|pm| pm.last_digits == payment.cc_number[-4,4] }).first

        # if this payment_method does not exist then create it.
        if @payment_method.nil? then
          puts 'Unable to find payment_method for client.  create new payment_method'
          # Create a new payment_method for client
          # Returns a new PaymentMethod instance or raises errors
          create_payment_method_for_client( 
            client, 
            first, 
            last, 
            payment.cc_number, 
            payment.ccv, 
            payment.exp_month, 
            payment.exp_year, 
            payment.address, 
            payment.city, 
            payment.state, 
            payment.zip
          )
        end
      end

      # at this point if payment_method is nil then there was an error creating it.
      if @payment_method then

        # Create a new transaction for an existing customer and payment method.
        # Returns a new Transaction instance if request was successful, otherwise
        # raises ArrowPayments::Error exception with error message.
        if payment.amount > 0 then 
          begin
            transaction = @arrow.create_transaction(  
              :customer_id        => client.id, 
              :payment_method_id  => @payment_method.id,
              :transaction_type   => 'sale',
              :total_amount       => payment.amount,
              :tax_amount         => 0,
              :shipping_amount    => 0,
              :description				=> description
            )
          rescue Exception => e
            puts "Exception caught in submit_online_payment @arrow.create_transaction #{e.message}"
            @error_message = e.message
          end
        end
      else
        puts "transaction could not be completed because no valid payment method exists"
      end
    rescue Exception => e
      puts "rescue caught in submit_online_payment #{e.message}"
      @error_message = e.message
      puts e.backtrace 
    end
    @error_message
	end
		
  def get_payment_methods_for_client(name)
    name_arr = name.split(/\W+/)
    first = name_arr.first.downcase
    last = name_arr.last.downcase

    # recurring payments assume that customer and payment methods exist
    client = get_client_by_name(first, last)
    if client then
      client.payment_methods.each do |method|
      puts "#{method.last_digits}  exp: #{method.expiration_month} / #{method.expiration_year}"
    end
    else
      puts "Client not found #{name}"
    end
  end

  def submit_recurring_payment(name, amount, description)

    @error_message = nil
    name_arr = name.split(/\W+/)
    first = name_arr.first.downcase
    last = name_arr.last.downcase

    # recurring payments assume that customer and payment methods exist
    client = get_client_by_name(first, last)

    if client then
      # grab one only
      @payment_method = client.payment_methods.last
      if @payment_method then
      # Create a new transaction for an existing customer and payment method.
      # Returns a new Transaction instance if request was successful, otherwise
      # raises ArrowPayments::Error exception with error message.
      begin 
        transaction = @arrow.create_transaction(
          :customer_id        => client.id, 
          :payment_method_id  => @payment_method.id,
          :transaction_type   => 'sale',
          :total_amount       => amount,
          :tax_amount         => 0,
          :shipping_amount    => 0,
          :description        => description
        )

      rescue Exception => e
        puts "rescue caught in submit_recurring_payment #{e.message}"
        @error_message = e.message
       puts e.backtrace 
      else
        puts "Transaction successful #{transaction}"
      end
    else
      @error_message = 'No valid payment method found for client #{name}'
    end
    else
      @error_message = 'Client not found. #{name}'
    end

    @error_message
  end
	
		
  def create_payment_method_for_client(	
    client,  
    first, 
    last, 
    cc_number, 
    ccv, 
    month, 
    year, 
    address, 
    city, 
    state, 
    zip
  )

    puts "Create new payment method for client"

  # Initialize a new billing address instance
  address = ArrowPayments::Address.new(	
    :address  => address,
    :city     => city,
    :state    => state,
    :zip      => zip,
    :phone    => client.phone
  )

    
    puts "create new payment method"
    # Initialize a new payment method instance
    begin
      payment = ArrowPayments::PaymentMethod.new( 
        :first_name       => first,
        :last_name        => last,
        :number           => cc_number,
        :security_code    => ccv,
        :expiration_month => month,
        :expiration_year  => year
      )
      

      # Step 1: Provide payment method customer and billing address
      url = @arrow.start_payment_method(client.id, 
                                        address)
      # Step 2: Add credit card information
      token = @arrow.setup_payment_method(url, 
                                          payment)

      # Step 3: Finalize payment method creation and add to customer
      @payment_method = @arrow.complete_payment_method(token)
      if @payment_method 
        client.payment_methods << @payment_method
      end

    rescue Exception => e
      puts "rescue caught in create_payment_method_for_client #{e.message}  the entire error #{e}"
      @error_message = e.message
      puts e.backtrace 
    end
  end

  def get_client_by_name(first, last)

    #match first and last name.  ignore case and middle initial
    client = nil
    @customers.each do |a_client|
      if a_client.name.split(/\W+/).first.downcase == first &&
        a_client.name.split(/\W+/).last.downcase == last then
        client = a_client
        puts "Found a Match #{client.name}"
        break
      end
    end
    client
  end
end
