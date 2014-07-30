class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :score
      t.string :options, limit: 5

      t.timestamps
    end
  end
end
