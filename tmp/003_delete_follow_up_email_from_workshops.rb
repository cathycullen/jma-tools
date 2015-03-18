class DeleteFollowUpEmailFromWorkshop < ActiveRecord::Migration
  def change
    remove_column :workshops, :follow_up_email
  end
end