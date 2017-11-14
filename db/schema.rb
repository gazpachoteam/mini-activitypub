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

ActiveRecord::Schema.define(version: 20171111215755) do

  create_table "activities", force: :cascade do |t|
    t.string "uri"
    t.string "action"
    t.bigint "object_id"
    t.string "object_type"
    t.boolean "local"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false, null: false
    t.bigint "person_id"
    t.index ["person_id"], name: "index_stream_entries_on_account_id"
    t.index [nil, nil], name: "index_stream_entries_on_activity_id_and_activity_type"
  end

  create_table "articles", force: :cascade do |t|
    t.string "uri"
    t.string "title"
    t.text "content"
    t.integer "person_id"
    t.boolean "local"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attention_requests", force: :cascade do |t|
    t.integer "person_id"
    t.integer "from_person_id"
    t.integer "activity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", force: :cascade do |t|
    t.integer "person_id"
    t.integer "target_person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string "username"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
