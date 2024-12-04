class Deal < ApplicationRecord
  enum :status, {open: "open", concluded: "concluded", terminated: "terminated"}
  has_one :payment_schedule
  has_many :payments, through: :payment_schedule
end
