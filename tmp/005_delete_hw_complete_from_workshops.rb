class DeleteHwCompleteFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :hw_complete
  end
end