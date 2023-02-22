class AddColumnToBattleCard < ActiveRecord::Migration[7.0]
  def change
    add_column :battle_cards, :counter, :integer
  end
end
