class Client < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :name

  belongs_to :coach
  belongs_to :category
end

def find_by_name(name)
  Client.where(:name => name).first
end
