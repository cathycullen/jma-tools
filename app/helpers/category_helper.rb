
class CategoryHelper
  def initialize
    @categories = categories
  end

  def categories
    @categories ||= Category.all
  end

  def get_categories
    @categories
  end
end
