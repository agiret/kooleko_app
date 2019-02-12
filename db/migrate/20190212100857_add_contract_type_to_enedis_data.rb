class AddContractTypeToEnedisData < ActiveRecord::Migration[5.2]
  def change
    add_column :enedis_data, :contract_type, :string
  end
end
