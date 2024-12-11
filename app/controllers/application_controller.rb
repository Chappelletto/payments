class ApplicationController < ActionController::API
  class AuthenticationError < StandardError; end

  rescue_from AuthenticationError do |error|
    render json: {error: error.message}, status: 401
  end

  def authenticate!
    token = request.headers["X-Auth-Token"]
    raise AuthenticationError.new("X-Auth-Token is missing") if token.blank?
    raise AuthenticationError.new("X-Auth-Token is invalid") if token != ENV["API_TOKEN"]
  end
end
