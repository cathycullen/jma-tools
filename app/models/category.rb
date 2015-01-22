class Category < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  has_many :payments
  validates_presence_of :name


  def self.all_entries
    Category.all
  end

end
