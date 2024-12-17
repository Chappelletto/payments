RSpec.describe PaymentsApi do
  describe "#payments" do
    subject(:payments) { api_client.payments }

    let(:api_client) { described_class.new }

    it "returns payments" do
      # pp payments
    end
  end
end
