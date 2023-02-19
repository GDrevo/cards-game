class ChangeColumnNameInSkills < ActiveRecord::Migration[7.0]
  def change
    rename_column :skills, :type, :skill_type
  end
end
