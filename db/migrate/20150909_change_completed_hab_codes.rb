class ChangeCompletedHabCodes < ActiveRecord::Migration
  
  def up
    remove_column :hab_codes, :completed
    add_column :hab_codes, :completed, :datetime
  end

  def down
    remove_column :hab_codes, :completed
    add_column :hab_codes, :completed, :datetime
  end


end