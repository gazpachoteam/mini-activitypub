class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string :uri
      t.string :action
      t.bigint :object_id
      t.string :object_type
      t.boolean :local
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :hidden, default: false, null: false
      t.bigint :account_id
      t.index ["account_id"], name: "index_stream_entries_on_account_id"
      t.index ["object_id", "object_type"], name: "index_stream_entries_on_object_id_and_object_type"
    end
  end
end
