module Deals
  # Deals::Delete
  class Delete
    def call(deal)
      Deal.transaction do
        deal.payment_schedule&.payments&.each(&:destroy!)
        deal.payment_schedule&.destroy!
        deal.destroy!
      end
    end
  end
end
