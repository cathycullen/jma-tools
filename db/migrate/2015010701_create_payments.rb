class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.datetime :payment_date
      t.string :name
      t.references :coach
      t.float :amount
      t.string :status
      t.string :msg
      t.string :transaction_type
      t.references :category
    end
  end
end