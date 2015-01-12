class Category < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :name


  def self.all_entries
    Category.all
  end
end
