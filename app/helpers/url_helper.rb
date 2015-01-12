class UrlHelper
   def initialize
    puts "UrlHelper initialize"
    @url_root = url_root
  end
  def url_root
     if ENV['RACK_ENV'] == 'development' then
        "localhost:9393"
      else
        "https://"+APP_NAME+".herokuapp.com"
      end
  end
  def get_url_root
    @url_root
  end
end
