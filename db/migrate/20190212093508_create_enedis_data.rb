class CreateEnedisData < ActiveRecord::Migration[5.2]
  def change
    create_table :enedis_data do |t|
      t.references :housing, foreign_key: true
      t.string :usage_point_status
      t.string :meter_type
      t.string :segment
      t.string :subscribed_power
      t.string :last_activation_date
      t.string :distri_tarif
      t.string :offpeak_hours
      t.string :contract_status
      t.string :last_distri_tarif_change_date

      t.timestamps
    end
  end
end
