

class FormatDate
  property :date, DateTime

  def initialize
    @end_str = {1 => 'st', 2 => 'nd', 3 => 'rd', 4 =>'th', 5 =>'th', 6 => "th", 7 => "th", 8 => "th", 9 => "th", 0 => "th" }
  end
  def self.jma_date
    p = FormatDate.new
    p
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

end
