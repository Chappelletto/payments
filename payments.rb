# 1 если paid_date заполнен значит оплачен
#   - если  paid_date > date то платёж оплачен с просрочкой
#   - иначе оплачен вовремя

# 2 иначе не оплачен
#   - если date уже прошел, то платеж просрочен
#   - иначе платеж еще не наступил

# 1. определить дату, начала АКТИВНОЙ просрочки (если она есть)
# 2. определить продолжительность АКТИВНОЙ просрочки (если она есть)

# ответ  "2025-01-12" тип Date
# puts Date.today

require 'date'
require 'time'

data = [
  {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
  {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
  {date: "2025-01-31", paid_date: nil}, #-- просрочен
  {date: "2025-02-24", paid_date: nil} #-- не наступил -
]

def find_next_due_payment(payments) # найти следующий срочный платёж (если платёж сегодня, то он срочный)
  payments.each do |payment|
    if (Date.parse(payment[:date]) >= Date.today) && payment[:paid_date].nil?
      return payment
    end
  end
  nil
end

pp find_next_due_payment(data)