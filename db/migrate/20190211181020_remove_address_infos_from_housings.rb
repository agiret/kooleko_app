class RemoveAddressInfosFromHousings < ActiveRecord::Migration[5.2]
  def change
    remove_column :housings, :address, :string
    remove_column :housings, :cp, :integer
    remove_column :housings, :city, :string
  end
end
