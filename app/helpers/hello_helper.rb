
module HelloHelper
  puts "HelloHelper called"
  def url_root
     if ENV['RACK_ENV'] == 'development' then
        "localhost:9393"
      else
        "https://"+APP_NAME+".herokuapp.com"
      end
  end
end
