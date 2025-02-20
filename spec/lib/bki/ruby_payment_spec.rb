def find_overdue_start_date(payments) # найти дату начала просрочки
  payments.each do |payment|
    if payment.active_overdue? && !payment.paid?
      return payment.date
    end
  end
  nil
end

def find_payments_paid_with_overdue(payments) # найти все платежи оплаченные с просрочкой
  payments_with_overdue = []
  payments.each do |payment|
    if payment.paid_with_overdue?
      payments_with_overdue << payment.date
    end
  end
  payments_with_overdue
end

def find_next_due_payment(payments) # найти следующий срочный платёж (если платёж сегодня, то он срочный)
  payments.each do |payment|
    if payment.due?
      return payment.date
    end
  end
  nil
end

# active_overdue_duration
def active_overdue_duration(payments) # определить продолжительность АКТИВНОЙ просрочки
  payments.each do |payment|
    if payment.active_overdue?
      return (payment.date - Date.today).to_i.abs
    end
  end
  nil
end

# 1
RSpec.describe Bki::Payment do
  describe "#find_overdue_start_date" do
    let(:payments) do
      [
        Bki::Payment.new(Date.today, Date.today),   #  - вовремя
        Bki::Payment.new(Date.today, Date.today + 1),  # --  с просрочкой
        Bki::Payment.new(Date.today - 5, nil), #-- просрочен
        Bki::Payment.new(Date.today, Date.today)
      ]
    end

    subject(:overdue_start_date) do
      find_overdue_start_date(payments)
    end

    it "return overdue start date" do
      expect(overdue_start_date).to eq(Date.today - 5)
    end

    context "all payments overdue" do
      let(:payments) do
        [
          Bki::Payment.new(Date.new(2025, 1, 1), nil),
          Bki::Payment.new(Date.new(2025, 1, 12), nil),
          Bki::Payment.new(Date.new(2025, 1, 15), nil),
          Bki::Payment.new(Date.new(2025, 2, 12), nil)
        ]
      end

      it "return first date overdue" do
        expect(overdue_start_date).to eq(Date.new(2025, 1, 1))
      end
    end

    context "when all payment are paid" do
      let(:payments) do
        [
          Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),
          Bki::Payment.new(Date.new(2025, 1, 12), Date.new(2025, 1, 12)),
          Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 15)),
          Bki::Payment.new(Date.new(2025, 2, 12), Date.new(2025, 2, 12))
        ]
      end
      it "returns nil" do
        expect(overdue_start_date).to eq(nil)
      end
    end

    context "no overdue" do
      let(:payments) do
        [
          Bki::Payment.new(Date.today + 1.month, nil),
          Bki::Payment.new(Date.today + 2.month, nil),
          Bki::Payment.new(Date.today + 3.month, nil),
          Bki::Payment.new(Date.today + 4.month, nil)
        ]
      end
      it "return nil" do
        expect(overdue_start_date).to eq(nil)
      end
    end
  end
end

# 2
describe "#payments_paid_with_overdue" do
  subject(:payments_paid_with_overdue) do
    find_payments_paid_with_overdue(payments)
  end

  let(:payments) do
    [
      Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),   #  - вовремя
      Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 20)),  # --  с просрочкой
      Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
      Bki::Payment.new(Date.new(2025, 2, 12), nil)
    ]
  end

  it "return payments_paid_with_overdue" do
    expect(payments_paid_with_overdue).to eq([Date.new(2025, 1, 15)])
  end

  context "all payments overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), nil),
        Bki::Payment.new(Date.new(2025, 1, 12), nil),
        Bki::Payment.new(Date.new(2025, 1, 15), nil),
        Bki::Payment.new(Date.new(2025, 2, 12), nil)
      ]
    end

    it "return nil" do
      expect(payments_paid_with_overdue).to eq([])
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),
        Bki::Payment.new(Date.new(2025, 1, 12), Date.new(2025, 1, 12)),
        Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 15)),
        Bki::Payment.new(Date.new(2025, 2, 12), Date.new(2025, 2, 12))
      ]
    end
    it "returns []" do
      expect(payments_paid_with_overdue).to eq([])
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.today + 1.month, nil),
        Bki::Payment.new(Date.today + 2.month, nil),
        Bki::Payment.new(Date.today + 3.month, nil),
        Bki::Payment.new(Date.today + 4.month, nil)
      ]
    end
    it "return []" do
      expect(payments_paid_with_overdue).to eq([])
    end
  end
end

# # # 3
describe "#next_due_payment" do
  subject(:next_due_payment) do
    find_next_due_payment(payments)
  end

  let(:payments) do
    [
      Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),   #  - вовремя
      Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 20)),  # --  с просрочкой
      Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
      Bki::Payment.new(Date.new(2025, 2, 28), nil)
    ]
  end

  it "return next due payment" do
    expect(next_due_payment).to eq(Date.new(2025, 2, 28))
  end

  context "all payments overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), nil),   #  - вовремя
        Bki::Payment.new(Date.new(2025, 1, 15), nil),  # --  с просрочкой
        Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
        Bki::Payment.new(Date.new(2025, 2, 28), nil)
      ]
    end

    it "return first date" do
      expect(next_due_payment).to eq(Date.new(2025, 2, 28))
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),
        Bki::Payment.new(Date.new(2025, 1, 12), Date.new(2025, 1, 12)),
        Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 15)),
        Bki::Payment.new(Date.new(2025, 2, 12), Date.new(2025, 2, 12))
      ]
    end
    it "returns nil" do
      expect(next_due_payment).to eq(nil)
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.today + 1.month, nil),
        Bki::Payment.new(Date.today + 2.month, nil),
        Bki::Payment.new(Date.today + 3.month, nil),
        Bki::Payment.new(Date.today + 4.month, nil)
      ]
    end
    it "return nil" do
      expect(next_due_payment).to eq(Date.today + 1.month)
    end
  end
end

# # 4
describe "#overdue_duration" do
  subject(:overdue_duration) do
    active_overdue_duration(payments)
  end

  let(:payments) do
    [
      Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),   #  - вовремя
      Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 20)),  # --  с просрочкой
      Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
      Bki::Payment.new(Date.new(2025, 2, 28), nil)
    ]
  end

  it "return overdue start date" do
    expect(overdue_duration).to eq((Date.today - Date.new(2025, 1, 12)).to_i)
  end

  context "all payments overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), nil),   #  - вовремя
        Bki::Payment.new(Date.new(2025, 1, 15), nil),  # --  с просрочкой
        Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
        Bki::Payment.new(Date.new(2025, 2, 28), nil)
      ]
    end

    it "return time of overdue" do
      expect(overdue_duration).to eq((Date.today - Date.new(2025, 1, 1)).to_i)
    end
  end

  context "when all payment are paid" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),
        Bki::Payment.new(Date.new(2025, 1, 12), Date.new(2025, 1, 12)),
        Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 15)),
        Bki::Payment.new(Date.new(2025, 2, 12), Date.new(2025, 2, 12))
      ]
    end
    it "returns nil" do
      expect(overdue_duration).to eq(nil)
    end
  end

  context "no overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.today + 1.month, nil),
        Bki::Payment.new(Date.today + 2.month, nil),
        Bki::Payment.new(Date.today + 3.month, nil),
        Bki::Payment.new(Date.today + 4.month, nil)
      ]
    end
    it "return nil" do
      expect(overdue_duration).to eq(nil)
    end
  end
end
