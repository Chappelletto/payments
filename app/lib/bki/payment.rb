module Bki
  class Payment
    attr_accessor :date, :paid_date

    def initialize(date, paid_date)
      @date = date
      @paid_date = paid_date
    end

    def due? # срочный он или нет?
      @date >= Date.today
    end

    def paid? # оплачен он или нет?
      @paid_date.present?
    end

    def active_overdue? # есть ли по нему активная просрочка?
      !paid? && !due?
    end

    def paid_with_overdue? # оплачен с просрочкой?
      paid? && (@paid_date > @date)
    end

    def overdue_duration
      return if !active_overdue?

      (Date.today - date).to_i
    end

    def over_overdue?(next_payment)
      paid_date > next_payment.date
    end
  end
end
