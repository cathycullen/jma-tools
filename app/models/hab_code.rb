class HabCode < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :code
end

def find_by_code(code)
  HabCode.where(:code => code).first
end

def find_by_id(id)
  HabCode.find(id)
end
