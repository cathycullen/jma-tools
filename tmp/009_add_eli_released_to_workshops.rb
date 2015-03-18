class AddEliReleasedToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :eli_released, :boolean, :default => false
  end
end