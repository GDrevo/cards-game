class AddDefaultToHitPoints < ActiveRecord::Migration[7.0]
  def change
    change_column_default :battle_cards, :hit_points, 100
  end
end
