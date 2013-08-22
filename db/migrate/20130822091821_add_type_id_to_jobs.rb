class AddTypeIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :type_id, :integer
    add_index :jobs, :type_id
  end
end
