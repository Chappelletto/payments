RSpec.describe Deals::Create do
  describe "#call" do
    subject(:created_deal) { described_class.new.call(deal_params) }

    let(:deal_params) { {status: "open", contract_number: "K-100500"} }

    it "creates new deal" do
      expect { created_deal }.to change { Deal.count }.from(0).to(1)
      expect(created_deal).to have_attributes(status: "open", contract_number: "K-100500")
    end

    context "when contract number already taken" do
      before do
        Deal.create(status: "open", contract_number: deal_params[:contract_number])
      end

      it "fails with error" do
        expect { created_deal }
          .to raise_error(Deals::ContractNumberAlreadyTakenError)
          .and not_change { Deal.count }.from(1)
      end
    end
  end
end
