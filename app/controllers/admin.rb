enable :sessions

get '/admin' do
  erb :admin  , :layout => :admin_layout
end

get '/jma_test' do
  @@expiration_date = Time.now + (60 * 2)
  @errors = []
  #request.cookies['hubspotutk'] = "460861660091fa36df38ddb143bec1fa"
  #Srequest.cookies['WTF'] = "WTF"
  response.set_cookie('WTF', :value => "WTF", :expires => @@expiration_date)
  response.set_cookie('hubspotutk', :value => "12345", :expires => @@expiration_date)
  erb :jma_test 
end


post '/jma_test_results' do
  puts "params:  #{params}" 
  puts "cookies #{cookies}  size  #{cookies.count}  #{cookies.class}  #{cookies.first.class} " 

  puts "request.cookies #{request.cookies}"

  request.cookies.each do |cookie|
    puts "************************ cookie #{cookie}"

  end

  puts "*********** cookies hubspotutk #{request.cookies[:hubspotutk]}"
  puts "*********** cookies WTF #{request.cookies['WTF']}"

  puts "********************** cookies  _CareerCheetah_session  #{request.cookies[:_CareerCheetah_session]}"
end


