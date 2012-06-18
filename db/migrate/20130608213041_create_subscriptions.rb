class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user, :null => false
      t.date :started_on, :null => false
      t.date :expires_on, :null => false
      t.date :cancelled_on
      t.string :reference, :null => false
      t.string :plan, :null => false
      t.integer :interval_count, :default => 0
      t.string :card_type
      t.string :card_last4
      t.string :card_name

      t.timestamps
    end
    change_table :users do |t|
      t.string :name
      t.string :address_line1
      t.string :address_line2
      t.string :address_city
      t.string :address_zip
      t.string :country
    end
    add_index :subscriptions, :user_id
  end
end
