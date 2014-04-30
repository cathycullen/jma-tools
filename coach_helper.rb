module CoachHelper
require './coach'

  def initialize
    puts "initialize coach helper"
    @coaches = []
    yml = YAML.load_file("coach.yml") 
    yml.each do |k|
      puts "coach #{k['coach']} #{k['email']} #{k['phone']}"
      coach = Coach.new(k['coach'], 
      k['email'], 
      k['phone'])
      @coaches << coach
    end
  end

  def get_coach_by_name(name)
    retval = nil
    
    @coaches.each do |coach|
      if coach.name == name
        retval = coach
      end
    end
    retval
  end
  
end

