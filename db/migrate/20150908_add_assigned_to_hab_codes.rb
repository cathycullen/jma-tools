class AddAssignedToHabCodes < ActiveRecord::Migration
    def change
        add_column :hab_codes, :assigned, :boolean, :default => false
    end
end