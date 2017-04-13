class CreateGradeStandardWillBeModifieds < ActiveRecord::Migration
  def change
    create_table :grade_standard_will_be_modifieds do |t|
      t.integer :grade_standard_id
      t.string :name
      t.integer :percent_standard
      t.attachment :image
    end
  end
end
