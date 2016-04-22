class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.belongs_to :functionary, index: true
      t.string :description, index: true

      t.timestamps null: false
    end
  end
end
