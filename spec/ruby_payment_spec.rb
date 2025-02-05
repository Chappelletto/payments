def find_overdue_start_date(payments)
  payments.each do |payment|
    if (Date.today > Date.parse(payment[:date])) && (payment[:paid_date] == nil)
      return Date.parse(payment[:date])
    end
  end
  nil
end

def find_payment_paid_with_overdue(payments) # найти все платежи оплаченные с просрочкой
  paid_with_overdue = []
  payments.each do |payment|
    if payment[:paid_date].nil?
      break
    elsif payment[:paid_date] > payment[:date]
      paid_with_overdue << payment
    end
  end

  if paid_with_overdue == []
    nil
  else
    Date.parse(paid_with_overdue[0][:date])
  end
end

def find_next_payment(payments) # найти следующий срочный платёж (если платёж сегодня, то он срочный)
  payments.each do |payment|
    if payment[:paid_date] == nil
      return Date.parse(payment[:date])
    end
  end
  nil
end

def find_time_of_overdue(payments) # определить продолжительность АКТИВНОЙ просрочки
  payments.each do |payment|
    if payment[:paid_date] == nil
      return (Date.parse(payment[:date]) - Date.today).to_i.abs
    end
  end
  nil
end


RSpec.describe do
  subject(:time_of_overdue) do
    find_time_of_overdue(payments)
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
    expect(time_of_overdue).to eq(24)
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
      expect(time_of_overdue).to eq(35)
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
      expect(time_of_overdue).to eq(nil)
    end
  end

  # context "no overdue" do
  #   let(:payments) do
  #     [
  #       {date: (Date.today + 1.month).to_s, paid_date: nil},
  #       {date: (Date.today + 2.month).to_s, paid_date: nil},
  #       {date: (Date.today + 3.month).to_s, paid_date: nil},
  #       {date: (Date.today + 4.month).to_s, paid_date: nil}
  #     ]
  #   end
  #   it "return nil" do
  #     expect(time_of_overdue).to eq(nil)
  #   end
  # end
end

# на каждый случай отдельная функция и дискрайб

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

RSpec.describe do
  subject(:payment_paid_with_overdue) do
    find_payment_paid_with_overdue(payments)
  end

  let(:payments) do
    [
      {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
      {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
      {date: "2025-01-12", paid_date: nil}, #-- просрочен
      {date: "2025-02-12", paid_date: nil}
    ]
  end

  it "return payment_paid_with_overdue" do
    expect(payment_paid_with_overdue).to eq(Date.new(2025, 1, 15))
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
      expect(payment_paid_with_overdue).to eq(nil)
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
      expect(payment_paid_with_overdue).to eq(nil)
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
      expect(payment_paid_with_overdue).to eq(nil)
    end
  end
end


RSpec.describe do
  subject(:next_payment) do
    find_next_payment(payments)
  end

  let(:payments) do
  [
    {date: "2025-01-01", paid_date: "2025-01-01"},   #  - вовремя
    {date: "2025-01-15", paid_date: "2025-01-20"},  # --  с просрочкой
    {date: "2025-01-12", paid_date: nil}, #-- просрочен
    {date: "2025-02-12", paid_date: nil}
  ]
  end

  it "return next payment" do
    expect(next_payment).to eq(Date.new(2025, 1, 12))
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

    it "return first date" do
      expect(next_payment).to eq(Date.new(2025, 1, 1))
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
      expect(next_payment).to eq(nil)
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
      expect(next_payment).to eq(Date.today + 1.month)
    end
  end
end
