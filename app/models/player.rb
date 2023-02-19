class Player < ApplicationRecord
  belongs_to :user
  has_many :battle_cards
end
