class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :name, :null => false, :unique => true
      t.string :email, :null => false, :unique => true
      t.integer :amount
      t.boolean :paid, :default => false
      t.references :workshop
    end
  end
end