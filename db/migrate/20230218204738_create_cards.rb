class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :name
      t.string :card_type
      t.integer :hit_points
      t.integer :armor
      t.integer :power
      t.integer :speed
      t.references :player, foreign_key: true

      t.timestamps
    end
  end
end
