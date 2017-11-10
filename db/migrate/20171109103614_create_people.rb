class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
        t.string :username
        t.string :domain
        t.timestamps
    end
  end
end
