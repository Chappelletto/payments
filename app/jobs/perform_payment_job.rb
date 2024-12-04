class PerformPaymentJob
  include Sidekiq::Job

  def perform(payment_id)
    payment = Payment.find(payment_id)
    payment.status = "paid"
    payment.save!
  end
end
