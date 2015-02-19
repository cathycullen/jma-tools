class Guest < ActiveRecord::Base
  # Remember to create a migration!
  #add validation

  belongs_to :workshop

  def find_by_workshop(workshop_id)
    self.where(:workshop_id => workshop_id)
  end
end
  def try_this(workshop_id)
    Guest.where(:workshop_id => workshop_id)
  end
