module CCDateHelper
require 'date'

  
  def months
    i = 0
    months = []
    12.times {
      i = i + 1
      (( m = i.to_s).size==1 ? m.prepend("0") : m).to_s
      Date::MONTHNAMES[i].to_s[0..2]
      months << {:month_num => (( m = i.to_s).size==1 ? m.prepend("0") : m).to_s , :month_name => Date::MONTHNAMES[i].to_s[0..2]}
    }
    months
  end

  def years
    year = (Time.now.year) -1
    years =[]
    10.times {
      years << (year = year+1).to_s
    }
    years
  end
  
end


# <%= CCDateHelper.months %>
