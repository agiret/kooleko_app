class RemovePdlToHousings < ActiveRecord::Migration[5.2]
  def change
    remove_column :housings, :pdl
  end
end
