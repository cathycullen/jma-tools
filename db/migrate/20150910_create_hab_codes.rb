class CreateHabCodes < ActiveRecord::Migration
  def change
    create_table :hab_codes do |t|
      t.string :code, :null => false, :unique => true
      t.string :last_name
      t.string :first_name
      t.string :email, :unique => true
      t.datetime  :date_sent
      t.boolean :registered, :default => false
      t.boolean :assigned, :default => false
      t.datetime  :completed
      t.boolean :debriefed, :default => false
      t.boolean :report_sent, :default => false
      t.references :coach
    end
  end
end
