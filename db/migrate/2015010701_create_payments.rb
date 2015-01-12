class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.datetime :payment_date
      t.string :name
      t.integer :coach
      t.float :amount
      t.string :status
      t.string :msg
      t.string :session_id
      t.string :category
    end
  end
end