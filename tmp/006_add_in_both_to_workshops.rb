class AddInBothToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :in_both, :boolean
  end
end