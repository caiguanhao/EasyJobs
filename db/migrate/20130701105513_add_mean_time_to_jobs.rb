class AddMeanTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :mean_time, :float
  end
end
