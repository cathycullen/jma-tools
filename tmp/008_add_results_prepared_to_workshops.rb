class AddResultsPreparedToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :results_prepared, :boolean
  end
end