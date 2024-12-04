RSpec.describe "/api/deals", type: :request do
  def parsed_body
    JSON.parse(subject.body, symbolize_names: true) # symbolize чтобы вернул ключи символы
  end

  describe "GET /" do
    subject(:deals_response) do
      get "/api/deals", params: request_params
      # , request.headers["X-Auth-Token"] = "api-token"
      response
    end

    # let(:request_headers) { {"X-Auth-Token" => "api-token"} }
    let(:request_params) { {} }
    let(:deals) do
      [
        Deal.create!(contract_number: 1, status: "open"),
        Deal.create!(contract_number: 2, status: "terminated", created_at: 6.months.ago),
        Deal.create!(contract_number: 3, status: "terminated", created_at: 5.days.ago)
      ]
    end

    before do
      deals
    end

    it "returns deals list" do
      expect(deals_response).to have_http_status(200)
      expect(parsed_body).to eq(
        [
          {id: deals[0].id, contract_number: "1", status: "open"},
          {id: deals[1].id, contract_number: "2", status: "terminated"},
          {id: deals[2].id, contract_number: "3", status: "terminated"}
        ]
      )
    end

    context "when there are no deals in system" do
      let(:deals) { [] }

      it "returns empty list" do
        expect(deals_response).to have_http_status(200)
        expect(parsed_body).to eq([])
      end
    end

    context "with fiters by status" do
      let(:request_params) { {status: "open"} }

      it "returns deals with status open" do
        expect(deals_response).to have_http_status(200)
        expect(parsed_body).to eq([{id: deals[0].id, contract_number: "1", status: "open"}])
      end
    end

    context "with filter created_after" do
      let(:request_params) { {created_after: 10.days.ago, status: "terminated"} }

      it "returns deals by filters" do
        expect(deals_response).to have_http_status(200)
        expect(parsed_body).to eq(
          [{id: deals[2].id, contract_number: "3", status: "terminated"}]
        )
      end
    end

    context "with sort" do
      let(:request_params) { {order_created_at: :desc} }

      it "return deals with sort" do
        expect(deals_response).to have_http_status(200)
        expect(parsed_body).to eq(
          [
            {id: deals[0].id, contract_number: "1", status: "open"},
            {id: deals[2].id, contract_number: "3", status: "terminated"},
            {id: deals[1].id, contract_number: "2", status: "terminated"}
          ]
        )
      end
    end

    # context "when without auth token" do
    #   let(:request_headers) { {} }

    #   it "returns error" do
    #     expect(deals_response).to have_http_status(401)
    #     expect(parsed_body).to eq(error: "X-Auth-Token is missing")
    #   end
    # end

    # context "when invalid token" do
    #   let(:request_headers) { {"X-Auth-Token" => "123"} }

    #   it "return error" do
    #     expect(deals_response).to have_http_status(401)
    #     expect(parsed_body).to eq(error: "invalid X-Auth-Token ")
    #   end
    # end
  end

  describe "GET /:id" do
    subject(:deal_response) do
      get "/api/deals/#{deal.id}"
      response
    end

    let(:deal) { Deal.create!(contract_number: 2, status: "open") }

    it "return deal" do
      expect(deal_response).to have_http_status(200)
      expect(parsed_body).to eq(
        id: deal.id, contract_number: deal.contract_number, status: deal.status
      )
    end

    context "when requested deal is not exist" do
      before do
        deal.destroy!
      end

      it "returns not found" do
        expect(deal_response).to have_http_status(404)
        expect(parsed_body).to eq(error: "deal not found")
      end
    end
  end

  describe "POST /" do
    subject(:create_deal_response) do
      post "/api/deals", params: request_params, as: :json
      response
    end

    let(:request_params) { {contract_number: 500, status: "open"} }

    it "creates deal" do
      expect(Deal.count).to eq(0)
      expect(create_deal_response).to have_http_status(201)

      created_deal = Deal.first
      expect(parsed_body).to eq(
        {id: created_deal.id, contract_number: created_deal.contract_number, status: created_deal.status}
      )
      expect(Deal.count).to eq(1)
      expect(created_deal).to have_attributes(contract_number: "500", status: "open")
    end

    context "with invalid params" do
      let(:request_params) { {contract_number: nil, status: 1} }

      it "return error" do
        expect(create_deal_response).to have_http_status(400)
        expect(parsed_body).to eq(
          errors: {contract_number: ["must be an integer"], status: ["must be a string"]}
        )
        expect(Deal.count).to eq(0)
      end
    end
  end

  describe "PATCH /:id" do
    subject(:update_deal_response) do
      patch "/api/deals/#{deal.id}", params: request_params, as: :json
      response
    end

    let(:request_params) { {contract_number: 7000, status: "open"} }
    let(:deal) { Deal.create!(contract_number: 600, status: "open") }

    it "updates deal" do
      expect(update_deal_response).to have_http_status(200)
      expect(parsed_body).to eq(
        id: deal.id, contract_number: "7000", status: "open"
      )
      expect(deal.reload).to have_attributes(contract_number: "7000", status: "open")
    end

    context "when received only one parametr" do
      let(:request_params) { {status: "terminated"} }

      it "update deal" do
        aggregate_failures do
          expect(update_deal_response).to have_http_status(200)
          expect(parsed_body).to eq(id: deal.id, contract_number: "600", status: "terminated")
          expect(deal.reload).to have_attributes(contract_number: "600", status: "terminated")
        end
      end
    end

    context "with invalid params" do
      let(:request_params) { {status: 0} }

      it "returns error" do
        expect(update_deal_response).to have_http_status(400)
        expect(parsed_body).to eq(errors: {status: ["must be a string"]})
        expect(Deal.first.status).to eq("open")
        # ask: проверить что параметры сделки не изменились
      end
    end

    context "when deal is not exits" do
      before do
        deal.destroy!
      end

      it "returns error" do
        expect(update_deal_response).to have_http_status(404)
        expect(parsed_body).to eq(error: "deal not found")
      end
    end
  end

  describe "DELETE /:id" do
    subject(:delete_deal_response) do
      delete "/api/deals/#{deal.id}", as: :json
      response # returned value
    end

    let(:deal) { Deal.create!(contract_number: 5, status: "open") }

    it "deletes deal" do
      expect(delete_deal_response).to have_http_status(200)
      expect(parsed_body).to eq(id: deal.id, contract_number: "5", status: "open")
      expect(Deal.count).to eq(0)
    end

    context "when deal is not exists" do
      before do
        deal.destroy!
      end
      it "returns error" do
        expect(delete_deal_response).to have_http_status(404)
        expect(parsed_body).to eq(error: "deal not found")
      end
    end

    context "when deal with payment_schedule and payments" do
      let(:payment) do
        deal = Deal.create!(contract_number: "1", status: "open")
        payment_schedule = PaymentSchedule.create!(deal: deal)
        Payment.create!(amount: 2000, date: "2024-10-12", status: "paid",
          payment_schedule: payment_schedule)
      end

      it "deletes payment_schedule and payments" do
        expect(delete_deal_response).to have_http_status(200)
        # ask почему? contract_number: "5"
        expect(parsed_body).to eq(id: deal.id, contract_number: "5", status: "open")
        expect(Deal.count).to eq(0)
        expect(PaymentSchedule.count).to eq(0)
        expect(Payment.count).to eq(0)
      end
    end
  end
end
