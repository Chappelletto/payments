class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.integer :amount, null: false
      t.string :status, null: false
      t.date :date, null: false
      t.timestamps
    end
  end
end
