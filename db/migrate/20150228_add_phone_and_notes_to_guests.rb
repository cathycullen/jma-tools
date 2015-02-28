class AddPhoneAndNotesToGuests < ActiveRecord::Migration
  def change
    add_column :guests, :phone, :string
    add_column :guests, :notes, :text, :limit => 1024
  end
end