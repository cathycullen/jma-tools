class AddWorkshopTyhpeToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :workshop_type, :string
  end
end