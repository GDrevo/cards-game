class CreateBattleCards < ActiveRecord::Migration[7.0]
  def change
    create_table :battle_cards do |t|
      t.datetime :played_at
      t.boolean :dead, default: false
      t.references :player, null: false, foreign_key: true
      t.references :battle, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
