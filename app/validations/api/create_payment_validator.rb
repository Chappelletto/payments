module Api
  class CreatePaymentValidator < Dry::Validation::Contract
    json do
      required(:amount).value(:integer, gt?: 0)
      required(:date).value(:date)
      required(:status).value(:string, included_in?: Payment.statuses.values)
    end
  end
end
