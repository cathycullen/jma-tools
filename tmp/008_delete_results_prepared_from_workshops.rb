class DeleteResultsPreparedFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :results_prepared
  end
end
