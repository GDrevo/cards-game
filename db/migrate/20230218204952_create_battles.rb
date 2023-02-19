class CreateBattles < ActiveRecord::Migration[7.0]
  def change
    create_table :battles do |t|
      t.string :result
      t.references :player_a, null: false
      t.references :player_b, null: false

      t.timestamps
    end
    add_foreign_key :battles, :players, column: :player_a_id
    add_foreign_key :battles, :players, column: :player_b_id
  end
end
