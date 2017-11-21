class AddAccountIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :account_id, :bigint, null: false
  end
end
