class DeleteResultsBackFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :results_back
  end
end
