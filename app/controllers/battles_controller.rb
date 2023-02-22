class BattlesController < ApplicationController
  def new
    @battle = Battle.new
  end

  def create
    Player.create(name: "Player 1", user: current_user) unless current_user.player
    @battle = Battle.create(player_a: current_user.player, player_b: Player.all.sample)
    # Pick 5 random cards for player_a and player_b depending on the choice made by user
    players_deck = []
    opponents_deck = []
    light_cards = Card.where(card_type: "light")
    dark_cards = Card.where(card_type: "dark")
    if battle_params[:side] == "light"
      while players_deck.size < 5
        card = light_cards.sample
        battle_card = BattleCard.new(player: @battle.player_a, battle: @battle, card:)
        battle_card.save unless players_deck.any? { |bc| bc.card.id == battle_card.card.id }
        players_deck << battle_card unless players_deck.any? { |bc| bc.card.id == battle_card.card.id }
      end
      while opponents_deck.size < 5
        card = dark_cards.sample
        battle_card = BattleCard.new(player: @battle.player_b, battle: @battle, card:)
        battle_card.save unless opponents_deck.any? { |bc| bc.card.id == battle_card.card.id }
        opponents_deck << battle_card unless opponents_deck.any? { |bc| bc.card.id == battle_card.card.id }
      end

    else
      while players_deck.size < 5
        card = dark_cards.sample
        battle_card = BattleCard.new(player: @battle.player_a, battle: @battle, card:)
        battle_card.save unless players_deck.any? { |bc| bc.card.id == battle_card.card.id }
        players_deck << battle_card unless players_deck.any? { |bc| bc.card.id == battle_card.card.id }
      end
      while opponents_deck.size < 5
        card = light_cards.sample
        battle_card = BattleCard.new(player: @battle.player_b, battle: @battle, card:)
        battle_card.save unless opponents_deck.any? { |bc| bc.card.id == battle_card.card.id }
        opponents_deck << battle_card unless opponents_deck.any? { |bc| bc.card.id == battle_card.card.id }
      end
    end
    redirect_to battle_path(@battle)
  end

  def show
    @battle = Battle.find(params[:id].to_i)
    @cards_player = @battle.player_a.battle_cards.where(battle: @battle).and(@battle.player_a.battle_cards.where(dead: false))
    @cards_opponent = @battle.player_b.battle_cards.where(battle: @battle).and(@battle.player_b.battle_cards.where(dead: false))
    if !@cards_player.all?(&:dead) && !@cards_opponent.all?(&:dead)
      @card_to_play = play_turn(@cards_player, @cards_opponent)
      session[:card_to_play_id] = @card_to_play.id
      @skills = @card_to_play.card.skills
    end

    if @cards_player.all?(&:dead)
      redirect_to game_over_path(@battle, winner: @battle.player_b.username)
    elsif @cards_opponent.all?(&:dead)
      redirect_to game_over_path(@battle, winner: @battle.player_a.username)
    else
      render :show
    end
  end

  def play_card
    battle = Battle.find(params[:id])
    player_cards = battle.player_a.battle_cards.where(battle: battle).and(battle.player_a.battle_cards.where(dead: false))
    opponents_cards = battle.player_b.battle_cards.where(battle: battle).and(battle.player_b.battle_cards.where(dead: false))
    all_cards = player_cards + opponents_cards
    skill_id = params[:skill]
    skill = Skill.find(skill_id)
    attacker = skill.card
    attackers_battle_card = (battle.player_a.battle_cards.where(card: attacker, battle: battle) + battle.player_b.battle_cards.where(card: attacker, battle: battle)).first
    target_battle_card = BattleCard.find(target_params[:target].to_i)
    target_card = target_battle_card.card
    target_battle_card.hit_points = target_card.hit_points unless target_battle_card.hit_points
    target_battle_card.save
    calculate_damage(attackers_battle_card, target_battle_card, skill)
    card_to_play = BattleCard.find(session[:card_to_play_id])
    card_to_play.counter = 0
    card_to_play.save
    session.delete(:card_to_play_id)
    redirect_to battle_path(battle)
  end

  def simulate_turn
    # 1. Get the skills the card_to_play can use, compute a simple logic to decide which to use
    # 2. Do the same for the opponent's card to target
    # 3. Calculate damage, lower hit_points and reset counter
    raise
    redirect_to battle_path(battle)
  end

  private

  def calculate_damage(attacker, target, skill)
    damage = attacker.card.power
    if skill.effect.include?("Light")
      damage = (damage * 0.75).round
    elsif skill.effect.include?("Powerful")
      damage = (damage * 1.25).round
    end
    target.hit_points -= damage
    target.dead = true if target.hit_points <= 0
    target.save
    attacker.counter = 0
    attacker.save
  end

  def play_turn(cards_player, cards_opponent)
    all_cards = cards_player + cards_opponent

    all_cards.each do |battle_card|
      battle_card.counter.nil? ? battle_card.counter = battle_card.card.speed : next
      battle_card.save
    end

    all_cards.sort_by! { |battle_card| battle_card.counter }
    all_cards.reverse!

    while all_cards.all? { |battle_card| battle_card.counter < 100 }
      all_cards.each do |battle_card|
        battle_card.counter += battle_card.card.speed
        battle_card.save
      end
    end
    all_cards.find { |battle_card| battle_card.counter > 100 }
  end

  def battle_params
    params.permit!
  end

  def target_params
    params.permit(:target)
  end
end
