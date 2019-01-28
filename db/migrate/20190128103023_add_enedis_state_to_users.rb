class AddEnedisStateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :enedis_state, :integer, unique: true
  end
end
