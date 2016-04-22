class CreateProclamations < ActiveRecord::Migration
  def change
    create_table :proclamations do |t|
      t.belongs_to :functionary, index: true
      t.string :global_id, index: true
      t.string :year, index: true
      t.string :adhibited_at, index: true
      t.boolean :satisfies_weird_conditions, index: true
      t.boolean :released_in_long_term, index: true
      t.string :entepreneur_activity, index: true
      t.string :administrative_functions, index: true

      t.timestamps null: false
    end
  end
end
