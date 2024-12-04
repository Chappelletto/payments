class CreatePaymentSchedule < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_schedules do |t|
      # должен принадлежать сделке
      t.references :deal, null: false, foreign_key: true, index: {unique: true}
      t.timestamps
    end
  end
end
