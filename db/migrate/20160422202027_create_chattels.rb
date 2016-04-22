class CreateChattels < ActiveRecord::Migration
  def change
    create_table :chattels do |t|
      t.belongs_to :proclamation, index: true
      t.integer :type, index: true
      t.string :description
      t.string :interest, index: true

      t.timestamps null: false
    end
  end
end
