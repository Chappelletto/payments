module Api
  class UpdateDealValidator < Dry::Validation::Contract
    json do
      optional(:contract_number).value(:integer, gt?: 0)
      optional(:status).value(:string, included_in?: Deal.statuses.values)
    end
  end
end
