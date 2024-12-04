RSpec.describe PerformPaymentJob do
  describe "#perform" do
    subject(:perform) {
      PerformPaymentJob.new.perform(payment.id)
    }

    let(:payment) do
      deal = Deal.create!(contract_number: 1, status: "open")
      payment_schedule = PaymentSchedule.create!(deal: deal)
      Payment.create!(amount: 1000, date: "2024-09-09", status: "pending",
        payment_schedule: payment_schedule)
    end

    it "update status" do
      expect(payment.status).to eq("pending")
      perform
      expect(payment.reload.status).to eq("paid")
    end
  end
end
