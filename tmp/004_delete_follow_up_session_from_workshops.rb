class DeleteFollowUpSessionFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :follow_up_session
  end
end