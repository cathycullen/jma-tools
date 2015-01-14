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

  def self.valid_entries
    Payment.where(:payment_date => Date.today, :status => VALID)
  end
  def self.invalid_entries
    Payment.where(:payment_date => Date.today, :status => ERROR)
  end
  def self.paid_entries
    Payment.where(:payment_date => Date.today, :status => PAID)
  end
  def self.total_payments
    Payment.where(:payment_date => Date.today, :status => PAID).sum(:amount)
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
end
