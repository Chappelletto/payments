RSpec.describe "/api/deal/:id/payment_schedule", type: :request do
  def parsed_body
    JSON.parse(subject.body, symbolize_names: true) # symbolize чтобы вернул ключи символы
  end

  describe "GET /" do
    subject(:payment_schedule_response) do
      get "/api/deals/#{deal.id}/payment_schedule"
      response
    end

    let(:deal) { Deal.create!(contract_number: 1, status: "open") }
    let(:payment_schedule) { PaymentSchedule.create!(deal: deal) }

    before do
      payment_schedule
    end

    it "returns payment_schedule" do
      expect(payment_schedule_response).to have_http_status(200)
      expect(parsed_body).to eq({id: payment_schedule.id, deal_id: deal.id})
    end

    context "when requested payment_schedule is not exist" do
      before do
        payment_schedule.destroy!
      end

      it "returns not found" do
        expect(payment_schedule_response).to have_http_status(404)
        expect(parsed_body).to eq(
          {error: "payment_schedule not found"}
        )
      end
    end
  end

  #-----------------------------------------------------------------------

  describe "POST /" do
    subject(:create_payment_schedule_response) do
      post "/api/deals/#{deal.id}/payment_schedule", params: request_params, as: :json
      response # returned value
    end

    let(:deal) do
      Deal.create!(contract_number: 1, status: "open")
    end

    context "no deal" do
      before do
        deal.destroy!
      end

      it "return error" do
        expect(Deal.count).to eq(0)
        expect(create_payment_schedule_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "deal not found"})
        expect(Payment_schedule.count).to eq(0)
      end
    end
  end
end
