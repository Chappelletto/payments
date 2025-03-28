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

    def xinterval_paid_overdue
      collected_intervals = {}
      tmp_payments = []
      number_interval = 1
      # исключаем из списка платежей оплаты вовремя и не наступившие платежи
      payments_temp = payments.reject { |payment| payment.paid_in_time? || payment.due? }
      # payments_temp.reject { |payment| payment.active_overdue? }
      # собрать ВСЕ интервалы, в которых платежи просачивались в нахлёст
      payments_temp.each_cons(2) do |current_payment, next_payment|
        if current_payment.continuous_overdue?(next_payment)
          tmp_payments << current_payment
          tmp_payments << next_payment
        else
          collected_intervals[number_interval] = tmp_payments
          tmp_payments = []
          number_interval += 1
        end
      end
      if tmp_payments.any?
        collected_intervals[number_interval] = tmp_payments
      end

      collected_intervals.delete_if do |_index, overdued_payments|
        overdued_payments.any?(&:active_overdue?)
      end
      return [] if collected_intervals == {}

      last_interval_index = collected_intervals.keys.max
      last_interval = collected_intervals[last_interval_index]
      return [] if last_interval[0]&.paid_date.nil?

      begin_date = last_interval[0].date
      end_date = last_interval[-1]&.paid_date
      result = [begin_date, end_date]
      # days_diff = (end_date - begin_date).to_i
      # puts "Начало интервала #{result[0]},конец интервала #{result[1]} продолжительность = #{days_diff}"
      result
    end

    def interval_paid_overdue
      last_paid_with_overdue_iterval = payments
        .select { |payment| payment.active_overdue? || payment.paid_with_overdue? }
        # группируем просрочки в интервалы "в нахлёст"
        .chunk_while { |cur_p, next_p| cur_p.continuous_overdue?(next_p) }
        # откидываем интервалы с активной просрочкой - они не погашены
        .reject { |collected_payments| collected_payments.any?(&:active_overdue?) }
        .last

      (last_paid_with_overdue_iterval.first.date...last_paid_with_overdue_iterval.last.paid_date)
    end
  end
end
