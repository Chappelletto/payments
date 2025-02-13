def find_overdue_start_date(payments)
  payments.each do |payment|
    if (Date.today > Date.parse(payment[:date])) && (payment[:paid_date] == nil)
      return Date.parse(payment[:date])
    end
  end
  nil
end

def find_payments_paid_with_overdue(payments) # найти все платежи оплаченные с просрочкой
  paid_with_overdue = []
  payments.each do |payment|
    if payment[:paid_date].nil?
      break
    elsif payment[:paid_date] > payment[:date]
      paid_with_overdue << payment
    end
  end
  paid_with_overdue
end

def find_next_due_payment(payments) # найти следующий срочный платёж (если платёж сегодня, то он срочный)
  payments.each do |payment|
    if (Date.parse(payment[:date]) >= Date.today) && payment[:paid_date].nil?
      return Date.parse(payment[:date])
    end
  end
  nil
end

# active_overdue_duration
def active_overdue_duration(payments) # определить продолжительность АКТИВНОЙ просрочки
  payments.each do |payment|
    if (payment[:paid_date] == nil) && Date.parse(payment[:date]) < Date.today
      return (Date.parse(payment[:date]) - Date.today).to_i.abs
    end
  end
  nil
end

# 1
RSpec.describe do
  subject(:overdue_start_date) do
    find_overdue_start_date(payments)
  end

  let(:payments) do
    [
      {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
      {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
      {date: "2025-01-12", paid_date: nil}, #-- просрочен
      {date: "2025-02-12", paid_date: nil}
    ]
  end

  it "return overdue start date" do
    expect(overdue_start_date).to eq(Date.new(2025, 1, 12))
  end

  context "all payments overdue" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: nil},
        {date: "2025-01-15", paid_date: nil},
        {date: "2025-01-12", paid_date: nil},
        {date: "2025-02-12", paid_date: nil}
      ]
    end

    it "return first date overdue" do
      expect(overdue_start_date).to eq(Date.new(2025, 1, 1))
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: "2025-01-01"},
        {date: "2025-01-15", paid_date: "2025-01-15"},
        {date: "2025-01-12", paid_date: "2025-01-12"},
        {date: "2025-02-12", paid_date: "2025-02-12"}
      ]
    end
    it "returns nil" do
      expect(overdue_start_date).to eq(nil)
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        {date: (Date.today + 1.month).to_s, paid_date: nil},
        {date: (Date.today + 2.month).to_s, paid_date: nil},
        {date: (Date.today + 3.month).to_s, paid_date: nil},
        {date: (Date.today + 4.month).to_s, paid_date: nil}
      ]
    end
    it "return nil" do
      expect(overdue_start_date).to eq(nil)
    end
  end
end

# 2
RSpec.describe do
  subject(:payments_paid_with_overdue) do
    find_payments_paid_with_overdue(payments)
  end

  let(:payments) do
    [
      {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
      {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
      {date: "2025-01-12", paid_date: nil}, #-- просрочен
      {date: "2025-02-12", paid_date: nil}
    ]
  end

  it "return payments_paid_with_overdue" do
    expect(payments_paid_with_overdue).to eq([{:date=>"2025-01-15", :paid_date=>"2025-01-20"}])
  end

  context "all payments overdue" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: nil},
        {date: "2025-01-15", paid_date: nil},
        {date: "2025-01-12", paid_date: nil},
        {date: "2025-02-12", paid_date: nil}
      ]
    end

    it "return nil" do
      expect(payments_paid_with_overdue).to eq([])
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: "2025-01-01"},
        {date: "2025-01-15", paid_date: "2025-01-15"},
        {date: "2025-01-12", paid_date: "2025-01-12"},
        {date: "2025-02-12", paid_date: "2025-02-12"}
      ]
    end
    it "returns []" do
      expect(payments_paid_with_overdue).to eq([])
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        {date: (Date.today + 1.month).to_s, paid_date: nil},
        {date: (Date.today + 2.month).to_s, paid_date: nil},
        {date: (Date.today + 3.month).to_s, paid_date: nil},
        {date: (Date.today + 4.month).to_s, paid_date: nil}
      ]
    end
    it "return []" do
      expect(payments_paid_with_overdue).to eq([])
    end
  end
end

# 3
RSpec.describe do
  subject(:next_due_payment) do
    find_next_due_payment(payments)
  end

  let(:payments) do
  [
    {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
    {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
    {date: "2025-01-12", paid_date: nil}, #-- просрочен
    {date: "2025-02-28", paid_date: nil}
  ]
  end

  it "return next due payment" do
    expect(next_due_payment).to eq(Date.new(2025, 2, 28))
  end

  context "all payments overdue" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: nil},
        {date: "2025-01-15", paid_date: nil},
        {date: "2025-01-12", paid_date: nil},
        {date: "2025-02-28", paid_date: nil}
      ]
    end

    it "return first date" do
      expect(next_due_payment).to eq(Date.new(2025, 2, 28))
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: "2025-01-01"},
        {date: "2025-01-15", paid_date: "2025-01-15"},
        {date: "2025-01-12", paid_date: "2025-01-12"},
        {date: "2025-02-12", paid_date: "2025-02-12"}
      ]
    end
    it "returns nil" do
      expect(next_due_payment).to eq(nil)
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        {date: (Date.today + 1.month).to_s, paid_date: nil},
        {date: (Date.today + 2.month).to_s, paid_date: nil},
        {date: (Date.today + 3.month).to_s, paid_date: nil},
        {date: (Date.today + 4.month).to_s, paid_date: nil}
      ]
    end
    it "return nil" do
      expect(next_due_payment).to eq(Date.today + 1.month)
    end
  end
end

# # 4
RSpec.describe do
  subject(:overdue_duration) do
    active_overdue_duration(payments)
  end

  let(:payments) do
    [
      {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
      {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
      {date: "2025-01-12", paid_date: nil}, #-- просрочен
      {date: "2025-02-12", paid_date: nil}
    ]
  end

  it "return overdue start date" do
    expect(overdue_duration).to eq((Date.today - Date.new(2025, 1, 12)).to_i)
  end

  context "all payments overdue" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: nil},
        {date: "2025-01-15", paid_date: nil},
        {date: "2025-01-12", paid_date: nil},
        {date: "2025-02-12", paid_date: nil}
      ]
    end

    it "return time of overdue" do
      expect(overdue_duration).to eq((Date.today - Date.new(2025, 1, 1)).to_i)
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        {date: "2025-01-01", paid_date: "2025-01-01"},
        {date: "2025-01-15", paid_date: "2025-01-15"},
        {date: "2025-01-12", paid_date: "2025-01-12"},
        {date: "2025-02-12", paid_date: "2025-02-12"}
      ]
    end
    it "returns nil" do
      expect(overdue_duration).to eq(nil)
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        {date: (Date.today + 1.month).to_s, paid_date: nil},
        {date: (Date.today + 2.month).to_s, paid_date: nil},
        {date: (Date.today + 3.month).to_s, paid_date: nil},
        {date: (Date.today + 4.month).to_s, paid_date: nil}
      ]
    end
    it "return nil" do
      expect(overdue_duration).to eq(nil)
    end
  end
end
