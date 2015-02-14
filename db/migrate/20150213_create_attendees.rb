class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.string :name, :null => false, :unique => true
      t.string :email, :null => false, :unique => true
      t.integer :amount
      t.boolean :paid, :default => false
    end
  end
end