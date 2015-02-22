class AddClientTypeAndLunchToGuests < ActiveRecord::Migration
  def change
    add_column :guests, :client_type, :string
    add_column :guests, :lunch, :text, :limit => 1024
  end
end
