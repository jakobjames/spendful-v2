require 'pg_db_helpers'

class CreateBudgets < ActiveRecord::Migration
  include PgDbHelpers::MigrationHelpers

  def up
    create_table :budgets do |t|
      t.references :user, :null => false
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :currency
      t.integer :initial_balance, :null => false, :default => 0
      t.timestamps
    end
    
    add_index :budgets, :user_id
    add_foreign_key :budgets, :user_id, :users
    add_unique_constraint :budgets, [:user_id, :name]
 end

  def down
    drop_table :budgets
  end
end
