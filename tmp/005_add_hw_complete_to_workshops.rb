class AddHwCompleteToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :hw_complete, :boolean
  end
end