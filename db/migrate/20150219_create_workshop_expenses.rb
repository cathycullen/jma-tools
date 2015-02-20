class CreateWorkshopExpenses < ActiveRecord::Migration
  def change
    create_table :workshop_expenses do |t|
      t.string :description
      t.float :amount
      t.references :workshop
    end
  end
end