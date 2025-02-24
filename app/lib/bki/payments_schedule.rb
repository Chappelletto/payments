module Bki
  class PaymentsSchedule
    attr_accessor :payments_schedule

    def initialize(payments_schedule)
      @payments_schedule = payments_schedule
    end

    def find_overdue_start_date # найти дату начала просрочки
      payments_schedule.find { |payment| payment.active_overdue? && !payment.paid? }&.date
    end

    def find_payments_paid_with_overdue # найти все платежи оплаченные с просрочкой
      payments_schedule.select(&:paid_with_overdue?)
    end

    def find_next_due_payment # найти следующий срочный платёж (если платёж сегодня, то он срочный)
      payments_schedule.find(&:due?)
    end

    # active_overdue_duration

    def active_overdue_duration # определить продолжительность АКТИВНОЙ просрочки
      payments_schedule.find(&:active_overdue?)&.overdue_duration
    end
  end
end
