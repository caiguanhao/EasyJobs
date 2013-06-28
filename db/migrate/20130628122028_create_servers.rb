class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :host
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
