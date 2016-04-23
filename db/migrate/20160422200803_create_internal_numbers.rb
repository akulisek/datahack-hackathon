class CreateInternalNumbers < ActiveRecord::Migration
  def change
    create_table :internal_numbers do |t|
      t.belongs_to :functionaries, index: true
      t.string :value, index: true

      t.timestamps null: false
    end
  end
end
