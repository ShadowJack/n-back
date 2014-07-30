class CreateProgressEntries < ActiveRecord::Migration
  def change
    create_table :progress_entries do |t|
      t.belongs_to :user
      t.string :opt, limit: 5
      t.integer :accuracy, limit: 2

      t.timestamps
    end
  end
end
