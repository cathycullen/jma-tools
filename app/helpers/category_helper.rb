
class CategoryHelper
  def initialize
    puts "initialize CategoryHelper"
    @categories = categories
  end

  def categories
    @categories ||= Category.all
  end

  def get_categories
    @categories
  end
end
