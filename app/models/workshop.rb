class Workshop < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :name
  validates_presence_of :workshop_date

  has_many :guests
  has_many :workshop_expenses
end
