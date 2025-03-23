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

ActiveRecord::Schema[8.0].define(version: 2025_03_23_150514) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "events", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "external_id", null: false
    t.string "title", null: false
    t.string "sell_mode", null: false
    t.string "organizer_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.index ["external_id"], name: "index_events_on_external_id", unique: true
    t.index ["sell_mode"], name: "index_events_on_sell_mode"
  end

  create_table "slots", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "external_id", null: false
    t.bigint "event_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "sell_from", null: false
    t.datetime "sell_to", null: false
    t.boolean "sold_out", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "current", default: true, null: false
    t.index ["current"], name: "index_slots_on_current"
    t.index ["event_id"], name: "index_slots_on_event_id"
    t.index ["starts_at", "ends_at"], name: "index_slots_on_starts_at_and_ends_at"
  end

  create_table "zones", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "external_id", null: false
    t.bigint "slot_id", null: false
    t.string "name", null: false
    t.integer "capacity", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.boolean "numbered", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slot_id"], name: "index_zones_on_slot_id"
  end

  add_foreign_key "slots", "events"
  add_foreign_key "zones", "slots"
end
