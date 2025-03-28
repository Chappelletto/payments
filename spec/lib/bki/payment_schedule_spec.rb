RSpec.describe Bki::PaymentsSchedule do
  describe "#overdue_start_date" do
    let(:payments) do
      [
        Bki::Payment.new(Date.today, Date.today),   #  - вовремя
        Bki::Payment.new(Date.today, Date.today + 1),  # --  с просрочкойoverdue_start_date
        Bki::Payment.new(Date.today - 5, nil), #-- просрочен
        Bki::Payment.new(Date.today, Date.today)
      ]
    end

    subject(:overdue_start_date) do
      Bki::PaymentsSchedule.new(payments).overdue_start_date
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

    context "when all payments are due" do
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
    Bki::PaymentsSchedule.new(payments).payments_paid_with_overdue
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
    expect(payments_paid_with_overdue).to eq([payments[1]])
  end

  context "when there are no paid payments" do
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

  context "when all payment are paid without overdue" do
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
end

# # # 3
describe "#next_due_payment" do
  subject(:next_due_payment) do
    Bki::PaymentsSchedule.new(payments).next_due_payment
  end

  let(:payments) do
    [
      Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),   #  - вовремя
      Bki::Payment.new(Date.new(2025, 1, 15), Date.new(2025, 1, 20)),  # --  с просрочкой
      Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
      Bki::Payment.new(Date.today + 1.day, nil)
    ]
  end

  it "return next due payment" do
    expect(next_due_payment).to eq(payments[3])
  end

  context "all payments overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), nil),   #  - вовремя
        Bki::Payment.new(Date.new(2025, 1, 15), nil),  # --  с просрочкой
        Bki::Payment.new(Date.new(2025, 1, 12), nil), #-- просрочен
        Bki::Payment.new(Date.today + 1.day, nil)
      ]
    end

    it "return first date" do
      expect(next_due_payment).to eq(payments[3])
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

  context "when all payments are due" do
    let(:payments) do
      [
        Bki::Payment.new(Date.today + 1.month, nil),
        Bki::Payment.new(Date.today + 2.month, nil),
        Bki::Payment.new(Date.today + 3.month, nil),
        Bki::Payment.new(Date.today + 4.month, nil)
      ]
    end
    it "return nil" do
      expect(next_due_payment).to eq(payments[0])
    end
  end
end

# # 4
describe "#overdue_duration" do
  subject(:overdue_duration) do
    Bki::PaymentsSchedule.new(payments).active_overdue_duration
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

  context "whe all payments are due" do
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

# interval
describe "#interval_paid_overdue" do
  subject(:interval_paid_overdue) do
    Bki::PaymentsSchedule.new(payments).interval_paid_overdue
  end

  let(:payments) do
    [
      Bki::Payment.new(Date.new(2025, 1, 1), Date.new(2025, 1, 1)),   #  - вовремя
      Bki::Payment.new(Date.new(2025, 2, 1), Date.new(2025, 3, 5)),  # --  с просрочкой
      Bki::Payment.new(Date.new(2025, 3, 1), Date.new(2025, 3, 10)),
      Bki::Payment.new(Date.new(2025, 4, 1), Date.new(2025, 4, 20)),
      Bki::Payment.new(Date.new(2025, 5, 22), nil)
    ]
  end

  it "return interval_paid_overdue" do
    expect(interval_paid_overdue).to eq([Date.new(2025, 2, 1), Date.new(2025, 3, 10)])
  end

  context "all payments overdue" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2025, 1, 1), nil),
        Bki::Payment.new(Date.new(2025, 1, 15), nil),
        Bki::Payment.new(Date.new(2025, 1, 12), nil),
        Bki::Payment.new(Date.new(2025, 2, 28), nil)
      ]
    end

    it "all payments overdue empty array" do
      expect(interval_paid_overdue).to be_empty
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
      expect(interval_paid_overdue).to eq([])
    end
  end

  # 2 платежа оплачены в срок
  # 2 платежа оплачены с просрочкой в нахлёст
  # 1 платёж оплачен вовремя
  # 3 платежа оплачены с просрочкой в нахлёст
  # 2 платежа, один оплачен с просрочкой, второй просрочен и не оплачен (эти два платежа не идут в нахлёст с предыдущей группой из 3х)

  context "many match periods" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2024, 1, 1), Date.new(2024, 1, 1)),
        Bki::Payment.new(Date.new(2024, 2, 1), Date.new(2024, 2, 1)),

        Bki::Payment.new(Date.new(2024, 3, 1), Date.new(2024, 4, 3)),
        Bki::Payment.new(Date.new(2024, 4, 1), Date.new(2024, 5, 1)),

        Bki::Payment.new(Date.new(2024, 5, 1), Date.new(2024, 5, 1)),

        Bki::Payment.new(Date.new(2024, 6, 1), Date.new(2024, 7, 5)),
        Bki::Payment.new(Date.new(2024, 7, 1), Date.new(2024, 8, 5)),
        Bki::Payment.new(Date.new(2024, 8, 1), Date.new(2024, 9, 1)),

        Bki::Payment.new(Date.new(2024, 9, 1), Date.new(2024, 10, 5)),
        Bki::Payment.new(Date.new(2024, 10, 1), nil)
      ]
    end

    it "last group with 3 payments" do
      expect(interval_paid_overdue).to eq([Date.new(2024, 6, 1), Date.new(2024, 9, 1)])
    end
  end

  context "many match periods" do
    let(:payments) do
      [
        Bki::Payment.new(Date.new(2024, 1, 1), Date.new(2024, 1, 1)),
        Bki::Payment.new(Date.new(2024, 2, 1), Date.new(2024, 2, 1)),

        Bki::Payment.new(Date.new(2024, 3, 1), Date.new(2024, 4, 3)),
        Bki::Payment.new(Date.new(2024, 4, 1), Date.new(2024, 5, 1)),

        Bki::Payment.new(Date.new(2024, 5, 1), Date.new(2024, 5, 1)),

        Bki::Payment.new(Date.new(2024, 6, 1), Date.new(2024, 7, 5)),
        Bki::Payment.new(Date.new(2024, 7, 1), Date.new(2024, 8, 5)),
        Bki::Payment.new(Date.new(2024, 8, 1), Date.new(2024, 9, 1)),

        Bki::Payment.new(Date.new(2024, 9, 1), Date.new(2024, 10, 5)),
        Bki::Payment.new(Date.new(2024, 10, 1), Date.new(2024, 10, 15))
      ]
    end

    it "last group with 3 payments" do
      expect(interval_paid_overdue).to eq((payments[-2].date...payments[-1].paid_date))
    end
  end
end
