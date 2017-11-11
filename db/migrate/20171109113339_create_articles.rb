class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
        t.string :uri
        t.string :title
        t.text  :content
        t.integer :person_id
        t.boolean :local
        t.timestamps
    end
  end
end
