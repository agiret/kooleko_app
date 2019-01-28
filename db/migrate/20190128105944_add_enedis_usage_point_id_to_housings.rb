class AddEnedisUsagePointIdToHousings < ActiveRecord::Migration[5.2]
  def change
    add_column :housings, :enedis_usage_point_id, :string, unique: true
  end
end
