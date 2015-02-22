class RenameWorkshopDate < ActiveRecord::Migration
  def change
    rename_column :workshops, :date, :workshop_date
  end
end


