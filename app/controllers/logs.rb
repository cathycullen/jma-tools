get '/logs' do
  redirect "/login" unless session[:user_id]

  Time.zone = "America/Chicago"
  @logs = Log.entries
  puts "last entry: #{Log.last.entry}"
  erb :logs 
end

def log_entry(entry_text)
  entry = Log.new
  end
