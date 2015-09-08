class DropHabCodes < ActiveRecord::Migration
  def up
    drop_table :hab_codes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end