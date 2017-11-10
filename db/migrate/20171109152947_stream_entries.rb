class StreamEntries < ActiveRecord::Migration[5.1]
  def change
    create_table "stream_entries", force: :cascade do |t|
      t.bigint "activity_id"
      t.string "activity_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "hidden", default: false, null: false
      t.bigint "person_id"
      t.index ["person_id"], name: "index_stream_entries_on_account_id"
      t.index ["activity_id", "activity_type"], name: "index_stream_entries_on_activity_id_and_activity_type"
    end
  end
end
