class FixIndexes < ActiveRecord::Migration
  def change
    add_index :jobs, :name, unique: true
    add_index :constants, :name, unique: true
    add_index :interpreters, :path, unique: true
    add_index :servers, :name, unique: true
  end
end
