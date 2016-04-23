class ChangeGainAndReimbursementTypeToCategory < ActiveRecord::Migration
  def change

    rename_column :gains, :type, :category
    rename_column :reimbursements, :type, :category

  end
end
