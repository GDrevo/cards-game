require 'faker'

Skill.destroy_all
BattleCard.destroy_all
Card.destroy_all

# TO DO: Create 10 "good" and 10 "evil" cards

# Attackers
yoda = Card.new(name: "Master Yoda", card_type: "light", hit_points: 100, armor: 15, power: 40, speed: 40)
yoda.save
anakin = Card.new(name: "Anakin Skywalker", card_type: "light", hit_points: 100, armor: 10, power: 50, speed: 35)
anakin.save
ahsoka = Card.new(name: "Ahsoka Tano", card_type: "light", hit_points: 100, armor: 20, power: 25, speed: 40)
ahsoka.save
luke = Card.new(name: "Luke Skywalker", card_type: "light", hit_points: 100, armor: 25, power: 50, speed: 20)
luke.save
leia = Card.new(name: "Princess Leïa", card_type: "light", hit_points: 100, armor: 10, power: 30, speed: 40)
leia.save

# Tanks
obiwan = Card.new(name: "Obi-Wan Kenobi", card_type: "light", hit_points: 100, armor: 50, power: 20, speed: 10)
obiwan.save
qui_gon = Card.new(name: "Qui-Gon Jin", card_type: "light", hit_points: 100, armor: 35, power: 30, speed: 20)
qui_gon.save
padme = Card.new(name: "Padme Amidala", card_type: "light", hit_points: 100, armor: 35, power: 20, speed: 30)
padme.save
han_solo = Card.new(name: "Han Solo", card_type: "light", hit_points: 100, armor: 45, power: 30, speed: 15)
han_solo.save
r2d2 = Card.new(name: "R2D2", card_type: "light", hit_points: 100, armor: 50, power: 10, speed: 30)
r2d2.save

# ATTACKERS
darth_vador = Card.new(name: "Darth Vader", card_type: "dark", hit_points: 100, armor: 15, power: 45, speed: 35)
darth_vador.save
emperor = Card.new(name: "The Emperor", card_type: "dark", hit_points: 100, armor: 20, power: 40, speed: 35)
emperor.save
darth_maul = Card.new(name: "Darth Maul", card_type: "dark", hit_points: 100, armor: 20, power: 25, speed: 40)
darth_maul.save
count_dooku = Card.new(name: "Count Dooku", card_type: "dark", hit_points: 100, armor: 25, power: 50, speed: 20)
count_dooku.save
grievous = Card.new(name: "General Grievous", card_type: "dark", hit_points: 100, armor: 10, power: 30, speed: 40)
grievous.save

# TANKS
tie_pilot = Card.new(name: "TIE Pilot", card_type: "dark", hit_points: 100, armor: 50, power: 20, speed: 10)
tie_pilot.save
imperial_guard = Card.new(name: "Imperial Guard", card_type: "dark", hit_points: 100, armor: 35, power: 30, speed: 20)
imperial_guard.save
general_veers = Card.new(name: "General Veers", card_type: "dark", hit_points: 100, armor: 30, power: 20, speed: 30)
general_veers.save
colonel_stark = Card.new(name: "Colonel Stark", card_type: "dark", hit_points: 100, armor: 45, power: 30, speed: 15)
colonel_stark.save
stormtrooper = Card.new(name: "Stormtrooper", card_type: "dark", hit_points: 100, armor: 50, power: 10, speed: 30)
stormtrooper.save

cards = Card.all

cards.each do |card|
  Skill.create(name: "Normal", skill_type: "Attack", effect: "Single Target", card:)
  if card.armor < 25
    Skill.create(name: "Multi", skill_type: "Attack", effect: "Multi Target Weak", card:)
    Skill.create(name: "Special", skill_type: "Attack", effect: "Single Target Powerful", card:)
  else
    Skill.create(name: "Multi", skill_type: "Heal", effect: "Single Target Powerful", card:)
    Skill.create(name: "Special", skill_type: "Heal", effect: "Multi Target Weak", card:)
  end
end

# Create players

20.times do
  user = User.create(email: Faker::Internet.safe_email, password: Faker::Internet.password)
  Player.create(name: Faker::Name.first_name, user:)
end
