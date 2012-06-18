# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130608213041) do

  create_table "budgets", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.string   "name",                           :null => false
    t.string   "slug",                           :null => false
    t.string   "currency"
    t.integer  "initial_balance", :default => 0, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "budgets", ["user_id", "name"], :name => "uc_budgets_user_id_name", :unique => true
  add_index "budgets", ["user_id"], :name => "index_budgets_on_user_id"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "items", :force => true do |t|
    t.integer  "budget_id",                            :null => false
    t.string   "category",                             :null => false
    t.string   "name",                                 :null => false
    t.string   "slug",                                 :null => false
    t.integer  "amount",                               :null => false
    t.string   "schedule",         :default => "once", :null => false
    t.date     "starts_on",                            :null => false
    t.date     "ends_on"
    t.text     "schedule_details"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "items", ["budget_id", "name", "starts_on"], :name => "uc_items_budget_id_name_starts_on", :unique => true
  add_index "items", ["budget_id"], :name => "index_items_on_budget_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.date     "started_on",                    :null => false
    t.date     "expires_on",                    :null => false
    t.date     "cancelled_on"
    t.string   "reference",                     :null => false
    t.string   "plan",                          :null => false
    t.integer  "interval_count", :default => 0
    t.string   "card_type"
    t.string   "card_last4"
    t.string   "card_name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "transactions", :force => true do |t|
    t.integer  "budget_id",   :null => false
    t.integer  "item_id"
    t.string   "category"
    t.date     "date",        :null => false
    t.integer  "amount",      :null => false
    t.string   "description"
    t.date     "occurrence"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "transactions", ["budget_id"], :name => "index_transactions_on_budget_id"
  add_index "transactions", ["item_id"], :name => "index_transactions_on_item_id"

  create_table "users", :force => true do |t|
    t.string   "uuid",            :null => false
    t.string   "email",           :null => false
    t.string   "password_digest", :null => false
    t.string   "password_token"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "name"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_city"
    t.string   "address_zip"
    t.string   "country"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["uuid"], :name => "index_users_on_uuid", :unique => true

end
