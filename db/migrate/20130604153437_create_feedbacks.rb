class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :user
      t.text :message

      t.timestamps
    end
    add_index :feedbacks, :user_id
  end
end
