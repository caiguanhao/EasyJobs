class AddServerIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :server_id, :integer
  end
end
