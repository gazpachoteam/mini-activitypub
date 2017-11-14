class AttentionRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :attention_requests do |t|
        t.integer :person_id
        t.integer :from_person_id
        t.integer :activity_id
        t.timestamps
    end
  end
end
