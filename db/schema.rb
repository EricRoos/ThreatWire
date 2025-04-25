# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_24_023757) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "public_token"
    t.string "token"
    t.string "token_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_accounts_on_token", unique: true
  end

  create_table "endpoint_events", force: :cascade do |t|
    t.string "event_type"
    t.string "endpoint_id"
    t.jsonb "raw_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.datetime "timestamp"
    t.string "message_id", null: false
    t.index ["account_id"], name: "index_endpoint_events_on_account_id"
    t.index ["endpoint_id", "message_id"], name: "index_endpoint_events_on_endpoint_id_and_message_id", unique: true
    t.index ["endpoint_id"], name: "index_endpoint_events_on_endpoint_id"
    t.index ["timestamp"], name: "events_timestamp_idx"
  end

  create_table "ssh_rejection_facts", force: :cascade do |t|
    t.string "ip"
    t.integer "port"
    t.string "ip_location"
    t.datetime "timestamp", null: false
    t.bigint "endpoint_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint_event_id"], name: "index_ssh_rejection_facts_on_endpoint_event_id"
    t.index ["timestamp"], name: "ssh_rejection_facts_timestamp_idx"
  end

  add_foreign_key "endpoint_events", "accounts"
end
