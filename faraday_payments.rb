require "faraday"
require "logger"

logger = Logger.new($stdout)

connection = Faraday.new("http://localhost:3000/") do |conn|
  # conn.request :logger
  conn.response :logger
  conn.response :json
end
response = connection.get("api/payments")

logger.info(response.status)
logger.info(response.body)


pp '======================================='
pp response.body[0]