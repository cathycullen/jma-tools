class AddFollowUpEmailToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :follow_up_email, :boolean
  end
end