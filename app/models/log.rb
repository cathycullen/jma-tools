class Log < ActiveRecord::Base

  validates_presence_of :entry

def self.new_entry(entry)
    log = self.new
    log.entry = entry
    Time.zone = "America/Chicago"
    log.entry_date = Time.now
    puts "log entry: #{entry}"
    log.save
  end

  def self.entries
    Log.all.order('id desc')
  end

  def self.search(name)
     Log.where("entry like '%#{name}%'")
  end

end

