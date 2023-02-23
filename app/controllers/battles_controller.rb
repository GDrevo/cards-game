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
    cards_player = @battle.player_a.battle_cards.where(battle: @battle).and(@battle.player_a.battle_cards.where(dead: false))
    @cards_player = cards_player.sort_by { |obj| obj.card.name }
    cards_opponent = @battle.player_b.battle_cards.where(battle: @battle).and(@battle.player_b.battle_cards.where(dead: false))
    @cards_opponent = cards_opponent.sort_by { |obj| obj.card.name }
    if !@cards_player.all?(&:dead) && !@cards_opponent.all?(&:dead)
      @card_to_play = play_turn(@cards_player, @cards_opponent)
      session[:card_to_play_id] = @card_to_play.id
      @skills = @card_to_play.card.skills
    end

    if @cards_player.empty?
      redirect_to battle_game_over_path(@battle, result: @battle.player_b)
    elsif @cards_opponent.empty?
      redirect_to battle_game_over_path(@battle, result: @battle.player_a)
    else
      render :show
    end
  end

  def game_over
    @battle = Battle.find(params[:battle_id])
    @winner = Player.find(params[:result])
  end

  def play_card
    battle = Battle.find(params[:id])
    players_deck = battle.battle_cards.where(player: battle.player_a).and(BattleCard.where(dead: false))
    opponents_deck = battle.battle_cards.where(player: battle.player_b).and(BattleCard.where(dead: false))
    skill_id = params[:skill]
    skill = Skill.find(skill_id)
    attacker = skill.card
    attackers_battle_card = (battle.player_a.battle_cards.where(card: attacker, battle: battle) + battle.player_b.battle_cards.where(card: attacker, battle: battle)).first
    if target_params[:target].to_i != 0
      target_battle_card = BattleCard.find(target_params[:target].to_i)
      target_card = target_battle_card.card
      target_battle_card.hit_points = target_card.hit_points unless target_battle_card.hit_points
      target_battle_card.save
    else
      target_battle_card = "multi target"
    end
    calculate_damage_player(attackers_battle_card, target_battle_card, skill, opponents_deck, players_deck)
    card_to_play = BattleCard.find(session[:card_to_play_id])
    card_to_play.counter = 0
    card_to_play.save
    session.delete(:card_to_play_id)
    redirect_to battle_path(battle)
  end

  def simulate_turn
    battle = Battle.find(params[:id])
    players_deck = battle.battle_cards.where(player: battle.player_a).and(BattleCard.where(dead: false))
    computers_deck = battle.battle_cards.where(player: battle.player_b).and(BattleCard.where(dead: false))
    # 1. Get the skills the card_to_play can use, compute a simple logic to decide which to use
    card_to_play = BattleCard.find(session[:card_to_play_id])
    skill = decision_skill(card_to_play, players_deck, computers_deck)
    # 2. Do the same for the opponent's card to target
    if skill.effect.include?("Multi")
      bc_target = players_deck if skill.skill_type == "Attack"
      bc_target = computers_deck if skill.skill_type == "Heal"
      bc_target.each do |target|
        target.hit_points = target.card.hit_points unless target.hit_points
        target.save
      end
    else
      bc_target = decision_target(players_deck, computers_deck, skill)
      bc_target.hit_points = bc_target.card.hit_points unless bc_target.hit_points
      bc_target.save
    end
    # 3. Calculate damage, lower hit_points and reset counter
    calculate_damage_computer(card_to_play, bc_target, skill, computers_deck, players_deck)
    card_to_play.counter = 0
    card_to_play.save
    session.delete(:card_to_play_id)
    redirect_to battle_path(battle)
  end

  private

  def decision_skill(card, players_deck, computers_deck)
    skills = card.card.skills
    heals = card.card.skills.select { |skill| skill.skill_type == "Heal" }
    attacks = card.card.skills.select { |skill| skill.skill_type == "Attack" }
    allies_alive = computers_deck.size
    ennemies_alive = players_deck.size
    allies_injured = (computers_deck.select { |battle_card| battle_card.hit_points.between?(1, 80) }).size
    ennemies_injured = (players_deck.select { |battle_card| battle_card.hit_points.between?(1, 80) }).size
    if (allies_alive.to_f / allies_injured) < 2
      if allies_injured.size > 1
        skill = (heals.select { |heal| heal.effect.include?("Multi") }).first
      end
      skill ||= (heals.select { |heal| heal.effect.include?("Single") }).first
    else
      if ennemies_alive.size > 1
        skill = (attacks.select { |attack| attack.effect.include?("Multi") }).first
      end
      skill ||= (attacks.select { |attack| attack.effect.include?("Single") }).first
    end
    skill.nil? ? skills.sample : skill
  end

  def decision_target(players_deck, computers_deck, skill)
    if skill.skill_type == "Heal"
      computers_deck.min_by(&:hit_points)
    elsif skill.skill_type == "Attack"
      players_deck.min_by(&:hit_points)
    end
  end

  def calculate_damage_player(attacker, target, skill, computers_deck, players_deck)
    damage = attacker.card.power
    if skill.effect.include?("Light")
      damage = (damage * 0.75).round
    elsif skill.effect.include?("Powerful")
      damage = (damage * 1.25).round
    end
    # raise
    if skill.effect.include?("Multi")
      if skill.skill_type == "Attack"
        targets = computers_deck
        targets.each do |target_multi|
          target_multi.hit_points = 100 unless target_multi.hit_points
          damage_multi = damage * (100 - target_multi.card.armor) / 100
          target_multi.hit_points -= damage_multi
          target_multi.dead = true if target_multi.hit_points <= 0
          target_multi.save
        end
      elsif skill.skill_type == "Heal"
        targets = players_deck
        targets.each do |target_multi|
          target_multi.hit_points = 100 unless target_multi.hit_points
          target_multi.hit_points += (damage / 1.25).round
          target_multi.hit_points = 100 if target_multi.hit_points > 100
          target_multi.save
        end
      end
    else
      if skill.skill_type == "Attack"
        damage_attack = damage * (100 - target.card.armor) / 100
        target.hit_points -= damage_attack
        target.dead = true if target.hit_points <= 0
        target.save
      elsif skill.skill_type == "Heal"
        target.hit_points += (damage / 1.25).round
        target.hit_points = 100 if target.hit_points > 100
        target.save
      end
    end

  end

  def calculate_damage_computer(attacker, target, skill, computers_deck, players_deck)
    damage = attacker.card.power
    if skill.effect.include?("Light")
      damage = (damage * 0.75).round
    elsif skill.effect.include?("Powerful")
      damage = (damage * 1.25).round
    end
    # raise
    if skill.effect.include?("Multi")
      if skill.skill_type == "Attack"
        targets = players_deck
        targets.each do |target_multi|
          target_multi.hit_points = 100 unless target_multi.hit_points
          damage_multi = damage * (100 - target_multi.card.armor) / 100
          target_multi.hit_points -= damage_multi
          target_multi.dead = true if target_multi.hit_points <= 0
          target_multi.save
        end
      elsif skill.skill_type == "Heal"
        targets = computers_deck
        targets.each do |target_multi|
          target_multi.hit_points = 100 unless target_multi.hit_points
          target_multi.hit_points += (damage / 1.25).round
          target_multi.hit_points = 100 if target_multi.hit_points > 100
          target_multi.save
        end
      end
    else
      if skill.skill_type == "Attack"
        damage_attack = damage * (100 - target.card.armor) / 100
        target.hit_points -= damage_attack
        target.dead = true if target.hit_points <= 0
        target.save
      elsif skill.skill_type == "Heal"
        target.hit_points += (damage / 1.25).round
        target.hit_points = 100 if target.hit_points > 100
        target.save
      end
    end

  end

  def play_turn(cards_player, cards_opponent)
    all_cards = cards_player + cards_opponent

    all_cards.each do |battle_card|
      battle_card.counter.nil? ? battle_card.counter = battle_card.card.speed : next
      battle_card.save
    end

    all_cards.sort_by!(&:counter)
    all_cards.reverse!

    while all_cards.all? { |battle_card| battle_card.counter < 100 }
      all_cards.each do |battle_card|
        battle_card.counter += (battle_card.card.speed / 10).round
        battle_card.save
      end
    end
    all_cards.find { |battle_card| battle_card.counter >= 100 }
  end

  def battle_params
    params.permit!
  end

  def target_params
    params.permit(:target)
  end
end
