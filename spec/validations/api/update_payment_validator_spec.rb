RSpec.describe Api::UpdatePaymentValidator do
  describe "#call" do
    subject(:validation_result) { described_class.new.call(params) }  # что это

    let(:params) do
      {amount: 60000, date: "2024-02-02", status: "paid"}
    end

    it "valid" do
      expect(validation_result).to be_success
      expect(validation_result.errors.to_h).to eq({})
    end

    context "when invalid params" do
      before do
        params[:amount] = "string"
        params[:date] = 1
        params[:status] = nil
      end

      it "invalid" do
        expect(validation_result).to be_failure
        expect(validation_result.errors.to_h).to eq(
          amount: ["must be an integer"], date: ["must be a date"], status: ["must be a string"]
        )
      end
    end

    context "when one parameter is missing" do
      before do
        params.delete(:amount)
      end

      it "valid" do
        expect(validation_result).to be_success
        expect(validation_result.errors.to_h).to eq({})
      end
    end

    context "when all params are missing" do
      let(:params) { {} }

      it "valid" do
        expect(validation_result).to be_success
        expect(validation_result.errors.to_h).to eq({})
      end
    end
  end
end
