class AddEmailSentToWorkshops < ActiveRecord::Migration
  def change
    add_column :workshops, :email_sent, :boolean
  end
end