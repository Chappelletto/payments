class PaymentsMock
  def self.payments(response_body: [{amount: 1000, status: "pending"}], response_status: 200)
    WebMock
      .stub_request(:get, "http://payments-service.host/api/payments")
      .with(headers: {"X-Auth-Token" => "api-token"})
      .to_return(
        status: response_status,
        body: response_body.to_json,
        headers: {"Content-Type" => "application/json"}
      )
  end

  def self.create_payment(
    request_body: {deal_id: 1, amount: 1000, date: "2024-12-12", status: "pending"},
    response_body: {deal_id: 1, amount: 1000, status: "paid", date: "2024-12-12"},
    response_status: 201
  )
    WebMock
      .stub_request(:post, "http://payments-service.host/api/payments")
      .with(
        body: request_body.to_json,
        headers: {"X-Auth-Token" => "api-token"}
      )
      .to_return(
        status: response_status,
        body: response_body.to_json,
        headers: {"Content-Type" => "application/json"}
      )
  end

  def self.payment(id:, response_body: [{amount: 1000, status: "pending"}], response_status: 200)
    WebMock
      .stub_request(:get, "http://payments-service.host/api/payments/#{id}")
      .with(headers: {"X-Auth-Token" => "api-token"})
      .to_return(
        status: response_status,
        body: response_body.to_json,
        headers: {"Content-Type" => "application/json"}
      )
  end

  def self.update_payment(
    id:,
    request_body:,
    response_body: {id: 1, amount: 1000, status: "paid", date: "2024-12-12"},
    response_status: 200
  )
    WebMock
      .stub_request(:patch, "http://payments-service.host/api/payments/#{id}")
      .with(headers: {"X-Auth-Token" => "api-token"}, body: request_body)
      .to_return(
        status: response_status,
        body: response_body.to_json,
        headers: {"Content-Type" => "application/json"}
      )
  end

  def self.delete_payment(id:, response_body:, response_status: 200)
    WebMock
      .stub_request(:delete, "http://payments-service.host/api/payments/#{id}")
      .with(headers: {"X-Auth-Token" => "api-token"})
      .to_return(status: response_status, body: response_body.to_json, headers: {"Content-Type" => "application/json"})
  end
end
