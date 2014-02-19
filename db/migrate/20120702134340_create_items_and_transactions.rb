require 'pg_db_helpers'

class CreateItemsAndTransactions < ActiveRecord::Migration
  include PgDbHelpers::MigrationHelpers

  def up
    create_table :items do |t|
      t.references :budget, :null => false
      t.string :category, :null => false
      t.string :name, :null => false
      t.string :slug, :null => false
      t.integer :amount, :null => false
      t.string :schedule, :null => false, :default => 'once'
      t.date :starts_on, :null => false
      t.date :ends_on
      t.text :schedule_details
      t.timestamps
    end

    create_table :transactions do |t|
      t.references :budget, :null => false
      t.references :item
      t.string :category
      t.date :date, :null => false
      t.integer :amount, :null => false
      t.string :description
      t.date :occurrence
      t.timestamps
    end

    add_index :items, :budget_id
    add_index :transactions, :budget_id
    add_index :transactions, :item_id
    add_foreign_key :items, :budget_id, :budgets
    add_foreign_key :transactions, :budget_id, :budgets
    add_foreign_key :transactions, :item_id, :items
    add_unique_constraint :items, [:budget_id, :name, :starts_on]
    add_check_constraint :items, :amount_greater_than_or_equal_to_zero, 'amount >= 0'
    add_check_constraint :transactions, :amount_greater_than_zero, 'amount > 0'
  end

  def down
    drop_table :transactions
    drop_table :items
  end
end
