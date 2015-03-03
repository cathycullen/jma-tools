class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.datetime :entry_date, :null => false
      t.string :entry, :null => false
    end
  end
end