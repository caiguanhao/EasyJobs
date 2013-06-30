class CreateConstants < ActiveRecord::Migration
  def change
    create_table :constants do |t|
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
