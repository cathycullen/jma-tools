class AddResultsBackToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :results_back, :boolean
  end
end