
class CoachHelper
  def initialize
    puts "initialize CoachHelper"
    @coaches = coaches
  end

  def categories
    @coaches ||= Coach.all
  end

  def get_coaches
    @coaches
  end
end
