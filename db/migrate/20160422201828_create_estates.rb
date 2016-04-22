class CreateEstates < ActiveRecord::Migration
  def change
    create_table :estates do |t|
      t.belongs_to :proclamation, index: true
      t.string :cadastral_area, index: true
      t.string :parcel_id, index: true
      t.string :lv_id, index: true
      t.string :interest, index: true

      t.timestamps null: false
    end
  end
end
