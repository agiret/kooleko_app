class AddEnedisRefreshTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :enedis_refresh_token, :string, null: false, default: ""
  end
end
