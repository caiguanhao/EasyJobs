class AddInterpreterToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :interpreter, :string
  end
end
