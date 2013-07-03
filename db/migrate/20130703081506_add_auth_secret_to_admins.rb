class AddAuthSecretToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :auth_secret, :string
  end
end
