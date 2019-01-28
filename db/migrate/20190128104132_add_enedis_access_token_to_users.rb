class AddEnedisAccessTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :enedis_access_token, :string, null: false, default: ""
  end
end
