class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :username, null: false, default: ''
      t.string :domain
      t.string :secret, null: false, default: ''
      t.text :private_key
      t.text :public_key
      t.text :note
      t.string :display_name, null: false, default: ''
      t.string :uri, null: false, default: ''
      t.string :url
      t.string :inbox_url, null: false, default: ''
      t.string :outbox_url, null: false, default: ''
      t.string :shared_inbox_url, null: false, default: ''
      t.string :followers_url, null: false, default: ''
      t.datetime :last_webfingered_at
      t.index [:uri], name: 'index_accounts_on_uri'
      t.index [:url], name: 'index_accounts_on_url'
      t.index [:username, :domain], name: 'index_accounts_on_username_and_domain', unique: true
      t.timestamps
    end
  end
end
