

require 'arrow_payments'
require './payment'

@arrow = ArrowPayments::Client.new(
      :api_key     => ENV['ARROW_API_KEY'],
      :mode        => ENV['ARROW_MODE'],
      :merchant_id => ENV['ARROW_MERCHANT_ID']
    )
    
@arrow.customers.last.payment_methods.first

