RSpec.describe Payment do
  describe "state-machine" do
    describe "#pay" do  # #-метод экземпляра
      subject(:pay_event) { payment.pay }

      let(:payment) { Payment.new }

      it "changes payment state from :pending to :paid" do
        expect(payment.status).to eq("pending")
        payment.pay
        expect(payment.status).to eq("paid")
      end
      it "saves paid_at" do
        expect(payment.paid_at).to eq(nil)
        freeze_time do
          payment.pay
          expect(payment.paid_at).to eq(Time.current)
        end
      end
    end
  end
end
