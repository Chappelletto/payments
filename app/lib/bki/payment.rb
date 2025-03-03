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

    def paid_in_time?
      return false if @paid_date.nil?
      @paid_date <= @date
    end

    # def continuous_overdue?(next_payment)
    #   return false if date > next_payment.date # платежи не идут друг за другом
    #   return true if active_overdue? && !next_payment.paid?
    #   return false if !paid?
    #   paid_date > next_payment.date
    # end

    def continuous_overdue?(next_payment)
      return false if date > next_payment.date # платежи не идут друг за другом
      return false if due? || paid_in_time? # у платежа нет или не было просрочки

      # строим интервалы [дата_платежа; дата_оплаты) и проверяем пересекаются ли они
      # если они пересеклись, то мы получили просрочку "в нахлёст"
      (date...paid_date).overlap?(next_payment.date...next_payment.paid_date)
    end
  end
end
