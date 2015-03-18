class AddDetailsToGuests < ActiveRecord::Migration
    def change
        add_column :guests, :follow_up_email, :boolean, :default => false
        add_column :guests, :email_sent, :boolean, :default => false
        add_column :guests, :follow_up_session, :boolean, :default => false
        add_column :guests, :hw_complete, :boolean, :default => false
        add_column :guests, :in_both, :boolean, :default => false
        add_column :guests, :results_back, :boolean, :default => false
        add_column :guests, :results_prepared, :boolean, :default => false
        add_column :guests, :eli_released, :boolean, :default => false
    end
end