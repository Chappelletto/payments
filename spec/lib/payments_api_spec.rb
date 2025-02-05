RSpec.describe PaymentsApi do
  let(:api_client) { described_class.new }

  describe "#payments" do
    subject(:payments) { api_client.payments }

    let(:payments_request) { PaymentsMock.payments }

    before do
      payments_request
    end

    it "returns payments" do
      expect(payments).to eq([{amount: 1000, status: "pending"}])
      expect(payments_request).to have_been_made.once
    end

    context "when returned empty list of payments" do
      let(:payments_request) { PaymentsMock.payments(response_body: []) }

      it "returns empty list" do
        expect(payments).to eq([])
        expect(payments_request).to have_been_made.once
      end
    end

    context "when server returns error" do
      let(:payments_request) { PaymentsMock.payments(response_status: 404) }

      it "raises error" do
        expect { payments }.to raise_error(Faraday::ResourceNotFound)
        expect(payments_request).to have_been_made.once
      end
    end
  end

  describe "#create_payment" do
    subject(:created_payment) { api_client.create_payment(deal_id: 1, amount: 1000, date: "2024-12-12") }

    let(:create_payment_request) { PaymentsMock.create_payment }

    before do
      create_payment_request
    end

    it "create payment" do
      expect(created_payment).to eq(deal_id: 1, amount: 1000, status: "paid", date: "2024-12-12")
      expect(create_payment_request).to have_been_made.once
    end

    context "when server returns error" do
      let(:create_payment_request) { PaymentsMock.create_payment(response_status: 404) }

      it "raises error" do
        expect { created_payment }.to raise_error(Faraday::ResourceNotFound)
        expect(create_payment_request).to have_been_made.once
      end
    end
  end

  describe "#payment" do
    subject(:payment) { api_client.payment(id: 1) }

    let(:payment_request) { PaymentsMock.payment(id: 1) }

    before do
      payment_request
    end

    it "returns payment" do
      expect(payment).to eq([{amount: 1000, status: "pending"}])
      expect(payment_request).to have_been_made.once
    end

    context "when payment is not found" do
      let(:payment_request) { PaymentsMock.payment(id: 1, response_status: 404) }

      it "raises error" do
        expect { payment }.to raise_error(Faraday::ResourceNotFound)
        expect(payment_request).to have_been_made.once
      end
    end
  end

  describe "#update_payment" do
    subject(:update_payment) { api_client.update_payment(id: 1, params: {amount: 1000, status: "paid"}) }

    let(:update_payment_request) { PaymentsMock.update_payment(id: 1, request_body: {amount: 1000, status: "paid"}) }

    before do
      update_payment_request
    end

    it "updates payment" do
      expect(update_payment).to eq(id: 1, amount: 1000, status: "paid", date: "2024-12-12")
      expect(update_payment_request).to have_been_made.once
    end

    context "when payment is not found" do
      let(:update_payment_request) do
        PaymentsMock.update_payment(id: 1, request_body: {amount: 1000, status: "paid"}, response_status: 404)
      end

      it "raises error" do
        expect { update_payment }.to raise_error(Faraday::ResourceNotFound)
        expect(update_payment_request).to have_been_made.once
      end
    end
  end

  describe "#delete" do
    subject(:delete_payment) { api_client.delete_payment(id: 1) }

    let(:delete_payment_request) do
      PaymentsMock.delete_payment(id: 1, response_body: {id: 1, amount: 1000, status: "paid", date: "2024-12-12"})
    end

    before do
      delete_payment_request
    end

    it "delete payment" do
      expect(delete_payment).to eq(id: 1, amount: 1000, status: "paid", date: "2024-12-12")
      expect(delete_payment_request).to have_been_made.once
    end

    context "when payment is not found" do
      let(:delete_payment_request) { PaymentsMock.delete_payment(id: 1, response_body: {}, response_status: 404) }

      it "raises error" do
        expect { delete_payment }.to raise_error(Faraday::ResourceNotFound)
        expect(delete_payment_request).to have_been_made.once
      end
    end
  end
end
