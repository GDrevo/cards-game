class CreateSkills < ActiveRecord::Migration[7.0]
  def change
    create_table :skills do |t|
      t.string :name
      t.string :type
      t.string :effect
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
