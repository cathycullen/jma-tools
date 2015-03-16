class Payment < ActiveRecord::Base
  # Remember to create a migration!
  #add validation
  validates_presence_of :name
  validates_presence_of :payment_date
  validates_presence_of :amount
  validates_presence_of :category
  validates_presence_of :coach
  validates_presence_of :transaction_type

  belongs_to :coach
  belongs_to :category

  scope :by_year, lambda { |year| where('extract(year from payment_date) = ?', year) }
  scope :by_month, lambda { |month| where('extract(month from payment_date) = ?', month) }
  scope :today, lambda { {
      :conditions => ["payment_date >= ?", Time.zone.now.beginning_of_day]
    }
  }


  scope :group_by_month,  lambda { group("date_trunc('month', payment_date) ") }
  scope :by_category, lambda { |category_id| where('category_id= ?', category_id) }

  def populate(name, amount, coach, category)
    self.name = name
    self.payment_date = Time.now
    self.amount = amount
    if !coach.nil?
      self.coach = coach
    end
    if !category.nil?
      self.category = category
    end
    self.status = PENDING
  end

  def self.format_money(number, delimiter = ',')
    number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
  end


  def self.valid_entries
    Payment.where(:payment_date => (Time.now.beginning_of_day..Time.now.end_of_day), :status => VALID)
  end
  def self.invalid_entries
    Payment.where(:payment_date => (Time.now.beginning_of_day..Time.now.end_of_day), :status => ERROR)
  end
  def self.paid_entries
    Payment.where(:status => PAID).order('payment_date desc')
  end
  def self.paid_entries_today
    Payment.where(:payment_date => (Time.now.beginning_of_day..Time.now.end_of_day), :status => PAID).order(:payment_date)
  end
  def self.total_payments_today
    Payment.where(:payment_date => (Time.now.beginning_of_day..Time.now.end_of_day), :status => PAID).sum(:amount)
  end
  def self.total_payments
    Payment.where(:status => PAID).sum(:amount)
  end
  def self.delete_invalid_entries
    Payment.where(:status => ERROR).delete_all
  end
  def self.pending_entries
    Payment.where(:payment_date => (Time.now.beginning_of_day..Time.now.end_of_day), :status => PENDING)
  end
  def self.pending_entries_new
    Payment.where(:payment_date => (Time.now.beginning_of_day..Time.now.end_of_day), :status => PENDING)
  end
  def self.delete_pending_entries
    Payment.where(:status => PENDING).delete_all
  end
  def self.filter_entries(name, coach, category, transaction_type, start_date, end_date)
    if start_date.nil?
    if !name.nil?
      self.search(name)
    else
      Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type).order('payment_date desc')
    end
    else
      self.filter_entries_by_date(coach, category, transaction_type, start_date, end_date)
    end
  end

  def self.filter_entries_by_date(coach, category, transaction_type, start_date, end_date)
    if end_date.nil?
      end_date = Date.today
    end
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, payment_date: start_date..end_date).order('payment_date desc')
  end

  def self.all_paid_entries
    Payment.where(:status => PAID).order('payment_date desc')
  end

  def self.sum_this_week(name, coach, category, transaction_type)
    if !name.nil?
      Payment.where(name: name, coach_id: coach, category_id: category, transaction_type: transaction_type, payment_date: Date.today.monday..Date.today, :status => PAID).sum('amount').to_i
    else
      Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, payment_date: Date.today.monday..Date.today, :status => PAID).sum('amount').to_i
    end
  end

  def self.sum_this_month(name, coach, category, transaction_type)
    if !name.nil?
      Payment.where(name: name, coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).by_month(Date.today.month).sum('amount').to_i
    else
      Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).by_month(Date.today.month).sum('amount').to_i
   end
 end
  
  def self.sum_this_year(name, coach, category, transaction_type)
    if !name.nil?
     Payment.where(name: name, coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).by_year(Date.today.year).sum('amount').to_i
   else
     Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).by_year(Date.today.year).sum('amount').to_i
    end
  end

  def self.sum_today(name, coach, category, transaction_type)
    if !name.nil?
     Payment.where(name: name, :payment_date => Date.today,coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).sum(:amount).to_i
   else
     Payment.where(:payment_date => Date.today, coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).sum(:amount).to_i
    end
  end
  def self.cagetory_groups(coach, category, transaction_type)
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).group(:category_id).sum('amount')
    Category.joins(:payments).group("categories.name").sum('amount')
  end

  def self.category_group_names(coach, category, transaction_type)
    categories = Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).group(:category_id).sum('amount')
    category_names = Hash.new
    categories.each do |entry|
      category_names.store Category.find_by_id(entry[0]).name, entry[1]
    end
    category_names.sort_by(&:last).reverse
  end

  def self.group_by_clients
    clients = Payment.where(:status => PAID).group(:name).sum('amount')
    clients.sort_by(&:last).reverse.take(10)
  end

  def self.group_by_months
    months = Payment.where(:status => PAID).group(:name).sum('amount')
    clients.sort_by(&:last).reverse
  end

  def self.last_12_months
    range = (Time.now.beginning_of_month - 11.months)..Time.now.end_of_month
    group_by_month(:payment_date, Time.zone, range).sum(:payment_amount)  
  end

  def self.monthly_summary
    results = []
    month_results = Payment.group("date_trunc('month', payment_date)").sum('amount')
    month_results.each do |entry|
      puts "entry[0] #{entry[0]}"
      key = "#{entry[0].strftime("%b")}  #{entry[0].strftime("%Y")}"
      results << {:month => key, :sum => entry[1]}
    end
  end
   def self.monthly_summary2
    results = []
    month_results = Payment.group("month_year").sum('amount')
    month_results.each do |entry|
      puts "entry[0] #{entry[0]}"
      key = "#{entry[0].strftime("%b")}  #{entry[0].strftime("%Y")}"
      results << {:month => key, :sum => entry[1]}
    end
  end


  #add monthly sum by category
  def self.monthly_summary_by_category
    results = []
    xx = []
    categories = Category.all
    categories.each do |category|
      month_results = Payment.where(:status => PAID, :category_id => category.id).group("DATE_TRUNC('month', payment_date)").sum('amount')
      month_results.each do |entry|
        puts "#{category.name}: #{entry[0]} #{entry[1]}"
        xx << "#{category.name}: #{entry[0]} #{entry[1]}"
        key = "#{entry[0].strftime("%b")}  #{entry[0].strftime("%Y")}"
        results << {:month => key, :sum => entry[1]}
      end
    end
      Payment.where(:status => PAID).group_by_month().sum('amount').to_i
  end

  def self.update_payment_month
    Payment.all.each do |payment|
      payment.month_year = payment.payment_date.strftime("%b") + " " + payment.payment_date.strftime("%Y")
      payment.save
    end
  end

  #def self.sum_this_category()
  #   Payment.where( :status => PAID), :group => "month_year".)by_category(1).sum('amount').to_i
  #end


  def self.search(name)
     Payment.where("name like '%#{name}%'")
  end
  
end
