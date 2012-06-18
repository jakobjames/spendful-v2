class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :uuid, :null => false
      t.string :email, :null => false
      t.string :password_digest, :null => false
      t.string :password_token
      t.timestamps
    end

    add_index :users, :email, :unique => true
    add_index :users, :uuid, :unique => true
  end

  def down
    drop_table :users
  end
end
