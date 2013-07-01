class CreateTimeStats < ActiveRecord::Migration
  def change
    create_table :time_stats do |t|
      t.float :real
      t.references :job, index: true
      t.integer :job_script_size

      t.timestamps
    end
  end
end
