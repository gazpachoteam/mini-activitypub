class CreateFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|

      t.timestamps
    end
  end
end
