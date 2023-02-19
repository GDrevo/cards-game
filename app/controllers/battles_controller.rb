class BattlesController < ApplicationController
  def new
    @battle = Battle.new
  end

  def create
    Player.create(name: "Player 1", user: current_user) unless current_user.player
    @battle = Battle.new(player_a: current_user.player, player_b: Player.all.sample)
    # Pick 5 random cards for player_a and player_b depending on the choice made by user
    if battle_params[:side] == "light"
      players_deck = []
      while players_deck.length < 5
        card = Card.where(card_type: "light").sample
        new_card = BattleCard.create(player: @battle.player_a, battle: @battle, card:)
        players_deck << new_card unless players_deck.include?(new_card)
      end
      opponents_deck = []
      while opponents_deck.length < 5
        card = Card.where(card_type: "dark").sample
        new_card = BattleCard.create(player: @battle.player_b, battle: @battle, card:)
        opponents_deck << new_card unless opponents_deck.include?(new_card)
      end
    else
      players_deck = []
      while players_deck.length < 5
        card = Card.where(card_type: "dark").sample
        new_card = BattleCard.create(player: @battle.player_a, battle: @battle, card:)
        players_deck << new_card unless players_deck.include?(new_card)
      end
      opponents_deck = []
      while opponents_deck.length < 5
        card = Card.where(card_type: "light").sample
        new_card = BattleCard.create(player: @battle.player_b, battle: @battle, card:)
        opponents_deck << new_card unless opponents_deck.include?(new_card)
      end
    end

    redirect_to battle_path(@battle)
  end

  def show
    @battle = Battle.find(params[:id])
  end

  private

  def battle_params
    params.permit!
  end
end
