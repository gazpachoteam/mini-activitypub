class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.string :uri
      t.integer :account_id
      t.boolean :local
      t.timestamps
      t.index ["account_id", "id"], name: "index_articles_on_account_id_id"
      t.index ["uri"], name: "index_articles_on_uri", unique: true
    end
  end
end
