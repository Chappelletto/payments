class PaymentSchedule < ApplicationRecord
  belongs_to :deal
  has_many :payments
end
