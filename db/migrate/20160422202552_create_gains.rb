class CreateGains < ActiveRecord::Migration
  def change
    create_table :gains do |t|
      t.belongs_to :proclamation, index: true
      t.integer :type, index: true
      t.integer :value, index: true
      t.string :currency, index: true

      t.timestamps null: false
    end
  end
end
