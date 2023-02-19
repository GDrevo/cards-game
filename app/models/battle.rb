class Battle < ApplicationRecord
  belongs_to :player_a, class_name: 'Player'
  belongs_to :player_b, class_name: 'Player'
end
