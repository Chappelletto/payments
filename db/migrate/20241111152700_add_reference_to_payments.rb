class AddReferenceToPayments < ActiveRecord::Migration[7.0]
  def change
    add_reference :payments, :payment_schedule, foreign_key: true, null: false
  end
end
