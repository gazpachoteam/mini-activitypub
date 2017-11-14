class Follows < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|
        t.integer :person_id
        t.integer :target_person_id
        t.timestamps
    end
  end
end
