class ChangeInterpreterColumn < ActiveRecord::Migration
  def change
    rename_column :jobs, :interpreter, :interpreter_id
    change_column :jobs, :interpreter_id, :integer
  end
end
