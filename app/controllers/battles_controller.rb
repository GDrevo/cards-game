class BattlesController < ApplicationController
  def new
    @battle = Battle.new
  end

  def create
    Player.create(name: "Player 1", user: current_user) unless current_user.player
    @battle = Battle.new(player_a: current_user.player, player_b: Player.all.sample)
    # Pick 5 random cards for player_a and player_b depending on the choice made by user
    players_deck = []
    opponents_deck = []
    if battle_params[:side] == "light"
      while players_deck.length < 5
        card = Card.where(card_type: "light").sample
        new_card = BattleCard.create(player: @battle.player_a, battle: @battle, card:)
        players_deck << new_card unless players_deck.include?(new_card)
      end
      while opponents_deck.length < 5
        card = Card.where(card_type: "dark").sample
        new_card = BattleCard.create(player: @battle.player_b, battle: @battle, card:)
        opponents_deck << new_card unless opponents_deck.include?(new_card)
      end
    else
      while players_deck.length < 5
        card = Card.where(card_type: "dark").sample
        new_card = BattleCard.create(player: @battle.player_a, battle: @battle, card:)
        players_deck << new_card unless players_deck.include?(new_card)
      end
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
    @cards_player = @battle.player_a.battle_cards.where(battle: @battle)
    @cards_opponent = @battle.player_b.battle_cards.where(battle: @battle)
    if !@cards_player.all?(&:dead) && !@cards_opponent.all?(&:dead)
      # card_played = play_turn(@battle.id, cards_player, cards_opponent)
      # break unless card_played[0]

      # @card = card_played[1]
      # return
      @card_to_play = play_turn(@battle.id, @cards_player, @cards_opponent)
    end

    if @cards_player.all?(&:dead)
      redirect_to game_over_path(@battle, winner: @battle.player_b.username)
    elsif @cards_opponent.all?(&:dead)
      redirect_to game_over_path(@battle, winner: @battle.player_a.username)
    else
      render :show
    end
  end

  private

  def play_turn(battle_id, cards_player, cards_opponent)
    # TO DO: Create the turn based logic using cards.speed and battle_card.played_at
    battle = Battle.find(battle_id)
    all_cards = cards_player + cards_opponent
    all_cards.sort_by! { |battle_card| battle_card.card.speed }
    all_cards.reverse!
    all_cards.each do |battle_card|
      battle_card.counter = battle_card.card.speed
    end
    while all_cards.all? { |battle_card| battle_card.counter < 100 }
      all_cards.each do |battle_card|
        battle_card.counter += battle_card.card.speed
      end
    end
    all_cards.find { |battle_card| battle_card.counter > 100 }
  end

  def play_card(battle_card)
    @available_skills = battle_card.card.skills
    raise
    # battle_card = BattleCard.find_by(id: session[:card_to_play_id])
    # redirect_to battle_path(battle_card.battle) unless battle_card.present?

    # skill = Skill.find_by(id: params[:selected_skill_id])
    # return redirect_to battle_path(battle_card.battle) unless skill.present? && battle_card.card.skills.include?(skill)

    # battle_card.perform_skill(skill)
    # session.delete(:card_to_play_id)
    # redirect_to battle_path(battle_card.battle)
  end

  def choose_skill(card)
    selected_skill_id = params[:skill] if params[:skill]
    # selected_skill = card.skills.find(selected_skill_id)
    raise
  end

  def battle_params
    params.permit!
  end
end
