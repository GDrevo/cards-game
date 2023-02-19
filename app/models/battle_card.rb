class BattleCard < ApplicationRecord
  belongs_to :player
  belongs_to :battle
  belongs_to :card
end
