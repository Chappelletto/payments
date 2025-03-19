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

    # интервал последней погашенной просрочки (дата начала, дата конца) дата начала просрочки? и дата оплаты в срок?

    #     Для этого нужно:
    #исключаем из списка платежей оплаты вовремя и не наступившие платежи
    # payments.reject { |payment| payment.paid_in_time? || payment.due? }
    # payments.select { |payment| payment.paid_with_overdue? || payment.active_overdue? }
      #     собрать ВСЕ интервалы, в которых платежи просачивались в нахлёст и были погашены
      #     исключаем из этого набора интервал, где есть активная просрочка (эта просрочка ещё не погашена)
      #     берём последний интервал

    # В довесок:
      #   нужно определять продолжительность интервала
      #     нужно определять начало интервала

    def interval_paid_overdue
      byebug
      payments.each_cons(2) do |current_payment, next_payment|
        # pp "current_payment=#{current_payment}, next_payment = #{next_payment}"
        # pp next_payment
        if (current_payment.continuous_overdue?(next_payment.date)) && !(current_payment.active_overdue?) #current_payment - это объект
          begin_date_overdue = current_payment.date
        else
          end_date_overdue = current_payment.paid_date
        end
      end

    #   # (date...paid_date).overlap?(next_payment.date...next_payment.paid_date)

    #   return [begin_date_overdue, end_date_overdue]
    end

    # def interval_paid_overdue
    #   result = []
    #   payments.each_cons(2) do |current_payment, next_payment|
    #     if (current_payment.date...current_payment.paid_date).overlap?(next_payment.date...next_payment.paid_date)
    #       begin_date_overdue = current_payment.date
    #     else
    #       end_date_overdue = current_payment.paid_date
    #     end
    #       pp [begin_date_overdue, end_date_overdue]
    #   end
    # end
  end
end

[
  Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),
  Bki::Payment.new(Date.new(2025, 1, 12), Date.new(2025, 1, 17)),
  Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 28)),
  Bki::Payment.new(Date.new(2025, 2, 12), Date.new(2025, 2, 12))
]