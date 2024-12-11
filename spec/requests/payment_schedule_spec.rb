RSpec.describe "/api/deal/:id/payment_schedule", type: :request do
  def parsed_body
    JSON.parse(subject.body, symbolize_names: true) # symbolize чтобы вернул ключи символы
  end

  describe "GET /" do
    subject(:payment_schedule_response) do
      get "/api/deals/#{deal.id}/payment_schedule", headers: request_headers
      response
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
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

    context "when without auth token" do
      let(:request_headers) { {} }
      it "returns error" do
        expect(subject).to have_http_status(401)
        expect(parsed_body).to eq(error: "X-Auth-Token is missing")
      end
    end

    context "when invalid token" do
      let(:request_headers) { {"X-Auth-Token" => "123"} }
      it "return error" do
        expect(subject).to have_http_status(401)
        expect(parsed_body).to eq(error: "X-Auth-Token is invalid")
      end
    end
  end

  #-----------------------------------------------------------------------

  describe "POST /" do
    subject(:create_payment_schedule_response) do
      post "/api/deals/#{deal.id}/payment_schedule", params: request_params, headers: request_headers, as: :json
      response # returned value
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:deal) do
      Deal.create!(contract_number: 1, status: "open")
    end

    let(:request_params) do
      {deal_id: deal.id}
    end

    context "when deal is not exsist" do
      before do
        deal.destroy!
      end

      it "return error" do
        expect(Deal.count).to eq(0)
        expect(create_payment_schedule_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "deal not found"})
        expect(PaymentSchedule.count).to eq(0)
      end
    end

    context "when payment schedule is already exist" do
      let(:deal) do
        Deal.create!(contract_number: 1, status: "open")
      end

      before do
        PaymentSchedule.create!(deal_id: deal.id)
      end
      it "return error" do
        expect(create_payment_schedule_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "payment schedule is already exist"})
      end
    end

    context "when without auth token" do
      let(:request_headers) { {} }
      it "returns error" do
        expect(subject).to have_http_status(401)
        expect(parsed_body).to eq(error: "X-Auth-Token is missing")
      end
    end

    context "when invalid token" do
      let(:request_headers) { {"X-Auth-Token" => "123"} }
      it "return error" do
        expect(subject).to have_http_status(401)
        expect(parsed_body).to eq(error: "X-Auth-Token is invalid")
      end
    end
  end
  #------------------------------------------------------------

  describe "DELETE /:id" do
    subject(:delete_payment_schedule_response) do
      delete "/api/deals/#{deal.id}/payment_schedule", headers: request_headers, as: :json
      response # returned value
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:deal) { Deal.create!(contract_number: 1, status: "open") }
    let(:payment_schedule) { PaymentSchedule.create!(deal_id: deal.id) }

    before do
      payment_schedule # let срабатывает когда его используют
    end

    it "deletes payment_schedule" do
      expect { delete_payment_schedule_response }.to change { PaymentSchedule.find_by(deal_id: deal.id) }.to(nil)
      expect(delete_payment_schedule_response).to have_http_status(200)
      expect(parsed_body).to eq(
        {deal_id: deal.id, id: payment_schedule.id}
      )
    end

    context "when payment_schedule is not exists" do
      before do
        payment_schedule.destroy!
      end
      it "returns error" do
        expect(delete_payment_schedule_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "payment_schedule not found"})
      end
    end

    context "when payments_schedule with payments" do
      before do
        payment_schedule.payments.create!(amount: 7000, date: Date.today)
      end

      it "deletes payment schedule with payments" do
        expect { delete_payment_schedule_response }
          .to change { PaymentSchedule.count }.from(1).to(0)
          .and change { Payment.count }.from(1).to(0)
        expect(delete_payment_schedule_response).to have_http_status(200)
        expect(parsed_body).to eq(deal_id: deal.id, id: payment_schedule.id)
      end
    end
  end

  context "when without auth token" do
    let(:request_headers) { {} }
    it "returns error" do
      expect(subject).to have_http_status(401)
      expect(parsed_body).to eq(error: "X-Auth-Token is missing")
    end
  end

  context "when invalid token" do
    let(:request_headers) { {"X-Auth-Token" => "123"} }
    it "return error" do
      expect(subject).to have_http_status(401)
      expect(parsed_body).to eq(error: "X-Auth-Token is invalid")
    end
  end
end
