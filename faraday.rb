require "faraday"
require "logger"

logger = Logger.new($stdout)

connection = Faraday.new("http://www.google.com") do |conn|
  # conn.request :logger
  conn.response :logger
end
response = connection.get("/")

logger.info(response.status)
logger.info(response.body)
