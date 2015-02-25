
class CategoryHelper
  def initialize
    puts "initialize CategoryHelper"
    @categories = categories
  end

  def categories
    @categories ||= Category.all.order('id')
  end

  def get_categories
    @categories
  end
end
