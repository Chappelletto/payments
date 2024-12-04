class AddPaidAtToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :paid_at, :datetime
  end
end
