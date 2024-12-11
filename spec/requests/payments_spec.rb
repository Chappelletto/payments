RSpec.describe "/api/payments", type: :request do
  def parsed_body
    JSON.parse(subject.body, symbolize_names: true) # symbolize чтобы вернул ключи символы
  end
  describe "GET /" do
    subject(:payments_response) do
      get "/api/payments", headers: request_headers
      response
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:payments) do
      deal = Deal.create!(contract_number: 1, status: "open")
      payment_schedule = PaymentSchedule.create!(deal: deal)
      [
        Payment.create!(
          amount: 30000, date: "2024-12-12", status: "paid",
          payment_schedule: payment_schedule
        ),
        Payment.create!(
          amount: 2000, date: "2024-10-12", status: "paid",
          payment_schedule: payment_schedule
        ),
        Payment.create!(
          amount: 3000, date: "2024-10-10", status: "pending",
          payment_schedule: payment_schedule
        )
      ]
    end

    before do
      payments
    end

    it "returns payments list" do
      expect(payments_response).to have_http_status(200)
      # expect(payments_response.status).to eq(200)
      expect(parsed_body).to eq(
        [
          {id: payments[0].id, amount: 30000, date: "2024-12-12", status: "paid"},
          {id: payments[1].id, amount: 2000, date: "2024-10-12", status: "paid"},
          {id: payments[2].id, amount: 3000, date: "2024-10-10", status: "pending"}

        ]
      )
    end

    context "when there are no data" do
      let(:payments) do
        []
      end

      it "return empty list" do
        expect(payments_response).to have_http_status(200)
        expect(parsed_body).to eq(
          []
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

  describe "GET /:id" do
    subject(:payment_response) do
      get "/api/payments/#{payment.id}", headers: request_headers
      response
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:payment) do
      deal = Deal.create!(contract_number: 1, status: "open")
      payment_schedule = PaymentSchedule.create!(deal: deal)
      Payment.create!(amount: 2000, date: "2024-10-12", status: "paid",
        payment_schedule: payment_schedule)
    end

    before do
      payment
    end

    it "return payment" do
      expect(payment_response).to have_http_status(200)
      expect(parsed_body).to eq(
        {id: payment.id, amount: 2000, date: "2024-10-12", status: "paid"}
      )
    end

    context "when requested payment is not exist" do
      before do
        payment.destroy!
        # deal.payment_schedule.destroy!
        # deal.destroy!
      end

      it "returns not found" do
        expect(payment_response).to have_http_status(404)
        expect(parsed_body).to eq(
          {error: "payment not found"}
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

  describe "POST /" do
    subject(:create_payment_response) do
      post "/api/payments", params: request_params, headers: request_headers, as: :json
      response # returned value
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:deal) do
      deal_1 = Deal.create!(contract_number: 1, status: "open")
      PaymentSchedule.create!(deal: deal_1)
      deal_1
    end

    let(:request_params) do
      {deal_id: deal.id, amount: 3000, date: "2024-09-09", status: "pending"}
    end

    it "creates payment" do
      expect(Payment.count).to eq(0)
      expect(create_payment_response).to have_http_status(201)

      created_payment = Payment.first
      expect(parsed_body).to eq(
        {id: created_payment.id, amount: 3000, date: "2024-09-09", status: "pending"}
      )
      expect(Payment.count).to eq(1)
      expect(created_payment).to have_attributes(amount: 3000, date: Date.new(2024, 9, 9),
        status: "pending", payment_schedule_id: deal.payment_schedule.id)
    end

    context "no deal" do
      before do
        deal.payment_schedule.destroy!
        deal.destroy!
      end

      it "return error" do
        expect(Payment.count).to eq(0)
        expect(create_payment_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "deal not found"})
        expect(Payment.count).to eq(0)
      end
    end

    context "no payments schedule" do
      before do
        deal.payment_schedule.destroy!
      end

      it "return error" do
        expect(Payment.count).to eq(0)
        expect(create_payment_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "payments schedule not found"})
        expect(Payment.count).to eq(0)
      end
    end

    context "invalid params" do
      let(:request_params) do
        {amount: nil, date: "invalid", status: 0}
      end

      it "return error" do
        expect(create_payment_response).to have_http_status(400)
        expect(parsed_body).to eq(
          {errors: {amount: ["must be an integer"], date: ["must be a date"], status: ["must be a string"]}}
        )
        expect(Payment.count).to eq(0)
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

  # -------------------------------------------------------------------------
  describe "PATCH /:id" do
    subject(:update_payment_response) do
      patch "/api/payments/#{payment.id}", params: request_params, headers: request_headers, as: :json
      response # returned value
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:request_params) do
      {amount: 10000, date: "2024-01-01", status: "pending"}
    end

    let(:payment) do
      deal = Deal.create!(contract_number: 1, status: "open")
      payment_schedule = PaymentSchedule.create!(deal: deal)
      Payment.create!(amount: 30000, date: "2024-12-12", status: "paid",
        payment_schedule: payment_schedule)
    end

    before do
      payment
    end

    it "updates payment" do
      expect(update_payment_response).to have_http_status(200)
      expect(parsed_body).to eq(
        {id: payment.id, amount: 10000, date: "2024-01-01", status: "pending"}
      )
      expect(payment.reload).to have_attributes(amount: 10000, date: Date.new(2024, 1, 1), status: "pending")
    end

    context "when received only one parametr" do
      let(:request_params) do
        {amount: 9999}
      end

      it "update payment" do
        aggregate_failures do
          expect(update_payment_response).to have_http_status(200)
          expect(parsed_body).to eq(
            {id: payment.id, amount: 9999, date: "2024-12-12", status: "paid"}
          )
          expect(payment.reload).to have_attributes(amount: 9999, date: Date.new(2024, 12, 12), status: "paid")
        end
      end
    end

    context "with invalid params" do
      let(:request_params) do
        {amount: "sdfa", date: "sdf", status: 0}
      end

      it "returns error" do
        expect(update_payment_response).to have_http_status(400)
        expect(parsed_body).to eq(
          {errors: {amount: ["must be an integer"], date: ["must be a date"], status: ["must be a string"]}}
        )
        expect(Payment.first).to have_attributes(amount: 30000, date: Date.new(2024, 12, 12), status: "paid")
      end
    end

    context "when payment is not exits" do
      before do
        payment.destroy!
      end

      it "returns error" do
        expect(update_payment_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "payment not found"})
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

  describe "DELETE /:id" do
    subject(:delete_payment_response) do
      delete "/api/payments/#{payment.id}", headers: request_headers, as: :json
      response # returned value
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:payment) do
      deal = Deal.create!(contract_number: "1", status: "open")
      payment_schedule = PaymentSchedule.create!(deal_id: deal.id)
      Payment.create!(amount: 30000, date: "2024-12-12", status: "paid",
        payment_schedule_id: payment_schedule.id)
    end

    it "deletes payment" do
      expect(delete_payment_response).to have_http_status(200)
      expect(parsed_body).to eq(
        {id: payment.id, amount: 30000, date: "2024-12-12", status: "paid"}
      )
      expect(Payment.find_by(id: payment.id)).to eq(nil)
    end

    context "when payment is not exists" do
      before do
        payment.destroy!
      end
      it "returns error" do
        expect(delete_payment_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "payment not found"})
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

  describe "POST /api/payments/:id/pay" do
    subject(:pay_payment_response) do
      post "/api/payments/#{payment.id}/pay", headers: request_headers, as: :json
      response # returned value
    end
    let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:payment) do
      deal = Deal.create!(contract_number: "1", status: "open")
      payment_schedule = PaymentSchedule.create!(deal_id: deal.id)
      Payment.create!(amount: 3000, date: Date.new(2024, 9, 9),
        status: "pending", payment_schedule_id: payment_schedule.id)
    end

    it "update payment" do
      expect(PerformPaymentJob.jobs.size).to eq(0)
      expect(pay_payment_response).to have_http_status(200)
      expect(parsed_body).to eq(
        {id: payment.id, amount: 3000, date: "2024-09-09", status: "pending"}
      )
      expect(PerformPaymentJob.jobs.size).to eq(1)
    end

    context "when payment is not exists" do
      before do
        payment.destroy!
      end
      it "returns error" do
        expect(pay_payment_response).to have_http_status(404)
        expect(parsed_body).to eq({error: "payment not found"})
        expect(PerformPaymentJob.jobs.size).to eq(0)
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
