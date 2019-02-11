class AddAddressInfosToHousings < ActiveRecord::Migration[5.2]
  def change
    add_column :housings, :address_street, :string
    add_column :housings, :address_locality, :string
    add_column :housings, :address_postal_code, :string
    add_column :housings, :address_insee_code, :string
    add_column :housings, :address_city, :string
    add_column :housings, :address_country, :string
  end
end
