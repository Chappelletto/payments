deals = [
  Deal.find_or_create_by!(contract_number: 111, status: "open"),
  Deal.find_or_create_by!(contract_number: 100, status: "concluded")
]

deals.each do |deal|
  # payment_schedule_1 = PaymentSchedule.find_or_create_by!(deal_id: deal_1.id)
  deal.create_payment_schedule! if deal.payment_schedule.nil?

  # Payment.find_or_create_by!(amount: 5000, status: "paid", date: "2024-01-01",
  #   payment_schedule_id: payment_schedule_1.id)
  deal.payment_schedule.payments.find_or_create_by(amount: 5000, status: "paid", date: "2024-01-01")
  deal.payment_schedule.payments.find_or_create_by(amount: 10000, status: "pending", date: "2024-02-02")
  deal.payment_schedule.payments.find_or_create_by(amount: 7000, status: "paid", date: "2024-03-03")
end
