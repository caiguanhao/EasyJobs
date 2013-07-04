class AddConstantIdToServers < ActiveRecord::Migration
  def change
    add_column :servers, :constant_id, :integer
    add_index :servers, :constant_id
  end
end
