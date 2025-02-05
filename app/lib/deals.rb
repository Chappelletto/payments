module Deals
  # Deals::ContractNumberAlreadyTakenError
  class ContractNumberAlreadyTakenError < StandardError
    attr_reader :contract_number

    def initialize(contract_number:)
      @contract_number = contract_number

      super("contract number already taken")
    end
  end
end
