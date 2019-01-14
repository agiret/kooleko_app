class CreateHousings < ActiveRecord::Migration[5.2]
  def change
    create_table :housings do |t|
      t.string :pdl
      t.string :address
      t.integer :cp
      t.string :city
      t.integer :surface_area
      t.string :heat_system
      t.string :hot_water_system

      t.timestamps
    end
  end
end
