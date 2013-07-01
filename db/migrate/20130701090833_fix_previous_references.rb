class FixPreviousReferences < ActiveRecord::Migration
  def change
    add_index :jobs, :server_id
    add_index :jobs, :interpreter_id
  end
end
