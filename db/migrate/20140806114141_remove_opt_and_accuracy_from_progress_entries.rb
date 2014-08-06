class RemoveOptAndAccuracyFromProgressEntries < ActiveRecord::Migration
  def change
    change_table :progress_entries do |t|
      t.remove :opt, :accuracy
      t.string :result, limit: 15
      t.integer :nsteps, limit: 2
    end
  end
end
