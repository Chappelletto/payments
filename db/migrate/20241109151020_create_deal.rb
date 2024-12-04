class CreateDeal < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      # id, contract_number: string, status: string(enum)
      t.string :contract_number, null: false, index: {unique: true}
      t.string :status, null: false
      t.timestamps
    end
  end
end
