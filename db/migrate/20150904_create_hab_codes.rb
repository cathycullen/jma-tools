class CreateHabCode < ActiveRecord::Migration
  def change
    create_table :hab_codes do |t|
      t.string :code, :null => false, :unique => true
      t.integer :coach_id,
      t.string :last_name,
      t.string :first_name,
      t.string :email, :unique => true
      t.datetime  :date_sent
      t.boolean :registered, :default => false
      t.boolean :completed, :default => false
      t.boolean :debriefed, :default => false
      t.boolean :report_sent, :default => false
      t.references :coach
    end
  end
end
