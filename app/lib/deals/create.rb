module Deals
  # Deals::Create
  class Create
    def call(deal_params)
      if Deal.where(contract_number: deal_params[:contract_number]).any?
        raise ContractNumberAlreadyTakenError.new(contract_number: deal_params[:contract_number])
      end

      Deal.create!(deal_params)
    end
  end
end
