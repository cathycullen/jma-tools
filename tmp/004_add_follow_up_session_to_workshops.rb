class AddFollowUpSessionToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :follow_up_session, :boolean
  end
end