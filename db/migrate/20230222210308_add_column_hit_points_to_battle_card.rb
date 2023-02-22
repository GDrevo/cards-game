class AddColumnHitPointsToBattleCard < ActiveRecord::Migration[7.0]
  def change
    add_column :battle_cards, :hit_points, :integer
  end
end
