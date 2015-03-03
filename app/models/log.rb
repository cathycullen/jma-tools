class Log < ActiveRecord::Base

  validates_presence_of :entry

def self.new_entry(entry)
    log = self.new
    log.entry = entry
    log.entry_date = Date.today
    log.save
  end

  def self.entries
    Log.all.order('entry_date desc')
  end

  def self.search(name)
     Log.where("entry like '%#{name}%'")
  end

end

