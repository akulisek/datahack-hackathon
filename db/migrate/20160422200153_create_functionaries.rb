class CreateFunctionaries < ActiveRecord::Migration
  def change
    create_table :functionaries do |t|
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :full_name, index: true
      t.string :surname_at_birth, index: true

      t.timestamps null: false
    end
  end
end
