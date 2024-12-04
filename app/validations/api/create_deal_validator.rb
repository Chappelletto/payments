module Api
  class CreateDealValidator < Dry::Validation::Contract
    json do
      required(:contract_number).value(:integer, gt?: 0)
      required(:status).value(:string, included_in?: Deal.statuses.values)
    end
  end
end
