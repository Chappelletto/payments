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

    def active_overdue_duration # определить продолжительность АКТИВНОЙ просрочки
      payments.find(&:active_overdue?)&.overdue_duration
    end

      # интервал последней погашенной просрочки (дата начала, дата конца) дата начала просрочки? и дата оплаты в срок?

      # Для этого нужно:
      # исключаем из списка платежей оплаты вовремя и не наступившие платежи
      # собрать ВСЕ интервалы, в которых платежи просачивались в нахлёсти были погашены
      # исключаем из этого набора интервал, где есть активная просрочка (эта просрочка ещё не погашена)
      # берём последний интервал

      # В довесок:
      #   нужно определять продолжительность интервала
      #   нужно определять начало интервала

    def interval_paid_overdue
      interval = {}
      tmp_payments = []
      number_interval = 1
      # исключаем из списка платежей оплаты вовремя и не наступившие платежи
      payments_temp = payments.reject { |payment| payment.paid_in_time? || payment.due? }
      payments_temp.reject { |payment| payment.active_overdue? }
      # собрать ВСЕ интервалы, в которых платежи просачивались в нахлёст
      payments_temp.each_cons(2) do |current_payment, next_payment|
        if current_payment.continuous_overdue?(next_payment)
          tmp_payments << current_payment
          tmp_payments << next_payment
          if interval == {}
            interval[number_interval] = tmp_payments
          end
        else  #условия продумать, если один интервал сюда не заходит
          interval[number_interval] = tmp_payments
          tmp_payments = []
          number_interval += 1
        end
      end
      return result = [] if interval == {}

      last_interval = interval[interval.keys.last]

      return nil if last_interval[0]&.paid_date.nil?

      begin_date = last_interval[0].date
      end_date = last_interval[-1]&.paid_date
      result = [begin_date, end_date]
      days_diff = (end_date - begin_date).to_i
      puts "Начало интервала #{result[0]},конец интервала #{result[1]} продолжительность = #{days_diff}"
      result
    end
  end
end
