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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171109152947) do

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.string "uri"
    t.integer "person_id"
    t.boolean "local"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "username"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stream_entries", force: :cascade do |t|
    t.bigint "activity_id"
    t.string "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false, null: false
    t.bigint "person_id"
    t.index ["activity_id", "activity_type"], name: "index_stream_entries_on_activity_id_and_activity_type"
    t.index ["person_id"], name: "index_stream_entries_on_account_id"
  end

end
