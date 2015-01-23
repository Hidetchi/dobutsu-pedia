class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.integer :bit_id, :limit => 8
      t.integer :num_end
      t.integer :best_id

      t.index :bit_id, :unique => true
    end
  end
end
