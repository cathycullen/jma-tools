class RemoveDetailsFromWorkshops < ActiveRecord::Migration
    def change
        remove_column :workshops, :follow_up_email, :boolean
        remove_column :workshops, :email_sent, :boolean
        remove_column :workshops, :follow_up_session, :boolean
        remove_column :workshops, :hw_complete, :boolean
        remove_column :workshops, :in_both, :boolean
        remove_column :workshops, :results_back, :boolean
        remove_column :workshops, :results_prepared, :boolean
        remove_column :workshops, :eli_released, :boolean
    end
end