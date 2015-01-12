
class CoachHelper
  def initialize
    @coaches = coaches
  end

  def categories
    @coaches ||= Coach.all
  end

  def get_coaches
    @coaches
  end
end
