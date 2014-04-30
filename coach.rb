class Coach
  attr_accessor :name,
                :email,
                :phone
                
  def initialize(name, email, phone)
     @name = name
     @email = email
     @phone = phone
  end 
end
