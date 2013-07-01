class FixInterpreterId < ActiveRecord::Migration
  def change
    change_column :jobs, :interpreter_id, :integer, :limit => nil
  end
end
