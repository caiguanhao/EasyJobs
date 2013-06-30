class CreateInterpreters < ActiveRecord::Migration
  def change
    create_table :interpreters do |t|
      t.string :path
      t.boolean :upload_script_first

      t.timestamps
    end
  end
end
