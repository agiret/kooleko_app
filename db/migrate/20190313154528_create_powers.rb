class CreatePowers < ActiveRecord::Migration[5.2]
  def change
    create_table :powers do |t|
      t.references :housing, foreign_key: true
      t.datetime :power_time
      t.integer :interval
      t.integer :power
      t.string :tariff_option

      t.timestamps
    end
  end
end
