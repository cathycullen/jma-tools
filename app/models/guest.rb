class Guest < ActiveRecord::Base
  # Remember to create a migration!
  #add validation

  belongs_to :workshop

  def find_by_workshop(workshop_id)
    self.where(:workshop_id => workshop_id)
  end
  
  def find_by_email(email)
    self.where(:email => email)
  end
end
  def try_this(workshop_id)
    Guest.where(:workshop_id => workshop_id)
  end
