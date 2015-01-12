
class CategoryHelper
  def initialize
    @categories = nil
  end

  def categories
    @categories ||= get_categories
  end

  def get_categories
    Category.all
  end

end
