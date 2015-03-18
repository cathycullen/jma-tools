class DeleteEliReleasedFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :eli_released
  end
end
