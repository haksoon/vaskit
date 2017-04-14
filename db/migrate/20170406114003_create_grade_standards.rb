class CreateGradeStandards < ActiveRecord::Migration
  def change
    create_table :grade_standards do |t|
      t.integer :grade_order, default: 0
      t.string :name
      t.integer :percent_standard, null: false
      t.integer :score_standard, default: 0
      t.attachment :image
    end

    create_table :grade_standard_will_be_modifieds do |t|
      t.integer :grade_standard_id
      t.string :name
      t.integer :percent_standard
      t.attachment :image
    end
  end
end
