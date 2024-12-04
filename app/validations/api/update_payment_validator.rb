module Api
  class UpdatePaymentValidator < Dry::Validation::Contract
    json do
      optional(:amount).value(:integer, gt?: 0)
      optional(:date).value(:date)
      optional(:status).value(:string, included_in?: Payment.statuses.values)
    end
  end
end
