module Bki
  class PaymentsSchedule
    attr_reader :payments

    def initialize(payments)
      @payments = payments
    end

    def overdue_start_date # найти дату начала просрочки
      payments.find { |payment| payment.active_overdue? && !payment.paid? }&.date
    end

    def payments_paid_with_overdue # найти все платежи оплаченные с просрочкой
      payments.select(&:paid_with_overdue?)
    end

    def next_due_payment # найти следующий срочный платёж (если платёж сегодня, то он срочный)
      payments.find(&:due?)
    end

    # active_overdue_duration

    def active_overdue_duration # определить продолжительность АКТИВНОЙ просрочки
      payments.find(&:active_overdue?)&.overdue_duration
    end
  end
end
