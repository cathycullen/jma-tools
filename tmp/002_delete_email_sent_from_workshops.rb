class DeleteEmailSentFromWorkshops < ActiveRecord::Migration
  def change
    remove_column :workshops, :email_sent
  end
end