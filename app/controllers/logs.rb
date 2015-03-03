get '/logs' do
  @logs = Log.entries
  erb :logs 
end

def log_entry(entry_text)
  entry = Log.new
  end
