class Payment < ApplicationRecord
  include AASM

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :paid # , :partly_paid

    event :pay do
      transitions from: :pending, to: :paid
      after do
        self.paid_at = Time.current
      end
    end
  end
  enum :status, {pending: "pending", paid: "paid"}
  scope :status, -> { where(status: "paid") }
  belongs_to :payment_schedule, inverse_of: :payments
end
