class HabCode < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :code
  belongs_to :coach

def find_by_code(code)
  HabCode.where(:code => code).first
end

def find_by_id(id)
  HabCode.find(id)
end

def self.get_assigned()
  HabCode.where(:assigned => true).order('date_sent')
end


def self.get_unassigned()
  HabCode.where(:assigned => false).order('code')
end

end
