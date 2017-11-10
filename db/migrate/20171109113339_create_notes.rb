class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
        t.text :content
        t.string :uri
        t.integer :person_id
        t.boolean :local
        t.timestamps
    end
  end
end
