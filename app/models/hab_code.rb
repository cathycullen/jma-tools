class HabCode < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :code
  validates :code, uniqueness: true
  belongs_to :coach

def find_by_code(code)
  HabCode.where(:code => code).first
end

def find_by_id(id)
  HabCode.find(id)
end

def self.get_assigned()
  HabCode.where(:assigned => true).includes(:coach).order('first_name')
end

def self.get_unassigned()
  HabCode.where(:assigned => false).includes(:coach).order('code')
end

def self.as_csv
  CSV.generate do |csv|
    csv << column_names
    all.each do |item|
      csv << item.attributes.values_at(*column_names)
    end
  end
end

end
