class DeleteInBothFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :in_both
  end
end