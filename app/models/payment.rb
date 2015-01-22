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

  def populate(name, amount, coach, category)
    self.name = name
    self.payment_date = Date.today
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
    Payment.where(:payment_date => Date.today, :status => VALID)
  end
  def self.invalid_entries
    Payment.where(:payment_date => Date.today, :status => ERROR)
  end
  def self.paid_entries
    Payment.where(:status => PAID).order(:payment_date)
  end
  def self.paid_entries_today
    Payment.where(:payment_date => Date.today, :status => PAID).order(:payment_date)
  end
  def self.total_payments_today
    Payment.where(:payment_date => Date.today, :status => PAID).sum(:amount)
  end
  def self.total_payments
    Payment.where(:status => PAID).sum(:amount)
  end
  def self.delete_invalid_entries
    Payment.where(:status => ERROR).delete_all
  end
  def self.pending_entries
    Payment.where(:payment_date => Date.today, :status => PENDING)
  end
  def self.delete_pending_entries
    Payment.where(:status => PENDING).delete_all
  end
  def self.filter_entries(coach, category, transaction_type)
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type)
  end

  def self.all_paid_entries
    Payment.where(:status => PAID).order(:payment_date)
  end

  def self.sum_this_week(coach, category, transaction_type)
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, payment_date: Date.today.monday..Date.today).sum('amount').to_i
  end

  def self.sum_this_month(coach, category, transaction_type)
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type).by_month(Date.today.month).sum('amount').to_i

  end
  
  def self.sum_this_year(coach, category, transaction_type)
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type).by_year(Date.today.year).sum('amount').to_i
  end

  def self.sum_today(coach, category, transaction_type)
    Payment.where(:payment_date => Date.today,coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).sum(:amount).to_i
  end
  def self.cagetory_groups(coach, category, transaction_type)
    Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).group(:category_id).sum('amount')
    #@category_chart {"Career Strategy"=>2900.0, "Life Coaching">=>10125.0, "Psychotherapy">=>1490.0,  "Trader Coaching">=>1350.0, "Career Coaching">=>38770.0, "Executive Coaching">=>1100.0, "Executive Coaching Individual">=>12025.0,  "Interview Coaching">=>1050.0, "ELI">=>9100.0}
    Category.joins(:payments).group("categories.name").sum('amount')
    #x = {"1" => 1000, "2" =>2000}

  end

  def self.category_group_names(coach, category, transaction_type)
    categories = Payment.where(coach_id: coach, category_id: category, transaction_type: transaction_type, :status => PAID).group(:category_id).sum('amount')
    category_names = Hash.new
    categories.each do |entry|
      category_names.store Category.find_by_id(entry[0]).name, entry[1]
    end
    category_names.sort_by(&:last).reverse
  end
end
