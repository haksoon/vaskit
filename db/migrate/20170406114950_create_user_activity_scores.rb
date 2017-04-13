class CreateUserActivityScores < ActiveRecord::Migration
  def change
    create_table :user_activity_scores do |t|
      t.integer :user_id
      t.integer :cycle_1_score, default: 0
      t.integer :cycle_2_score, default: 0
      t.integer :cycle_3_score, default: 0
      t.integer :cycle_4_score, default: 0
      t.integer :total_score, default: 0
      t.integer :grade_standard_id
    end
  end
end
