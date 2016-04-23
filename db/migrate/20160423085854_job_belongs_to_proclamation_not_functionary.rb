class JobBelongsToProclamationNotFunctionary < ActiveRecord::Migration
  def change
    rename_column :jobs, :functionary_id, :proclamation_id
  end
end
