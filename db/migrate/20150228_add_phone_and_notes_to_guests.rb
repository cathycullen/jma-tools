class AddMonthYearToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :month_year, :string
  end
end