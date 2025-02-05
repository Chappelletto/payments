class PaymentsApi
  def initialize
    @connection = Faraday.new(ENV["PAYMENTS_BASE_URL"]) do |conn|
      conn.response :logger, Rails.logger
      conn.response :raise_error
      conn.response :json, parser_options: {symbolize_names: true}

      conn.request :json

      conn.headers = {"X-Auth-Token" => ENV["API_TOKEN"]}
    end
  end

  def payments(filters: {}, sorts: {})
    response = @connection.get("payments") do |request|
      filters.each do |filter, value|
        request.params[filter] = value
      end

      sorts.each do |sort, value|
        request.params[sort] = value
      end
    end
    response.body
  end

  def payment(id:)
    @connection.get("payments/#{id}").body
  end

  def create_payment(deal_id:, amount:, date:)
    response = @connection.post("payments") do |req|
      req.body = {deal_id: deal_id, amount: amount, date: date, status: "pending"}.to_json
    end
    response.body
  end

  def update_payment(id:, params:)
    response = @connection.patch("payments/#{id}") do |req|
      req.body = params.to_json
    end
    response.body
  end

  def delete_payment(id:)
    @connection.delete("payments/#{id}").body
  end
end
