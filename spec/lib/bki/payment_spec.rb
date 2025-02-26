RSpec.describe Bki::Payment do
  describe "#due" do
    let(:payment) { Bki::Payment.new(Date.today + 1, nil) }

    subject(:due) do
      payment.due?
    end

    it "return true due" do
      expect(due).to eq(true)
    end

    context "no overdue" do
      let(:payment) { Bki::Payment.new(Date.today - 1, nil) }

      it "no overdue" do
        expect(due).to eq(false)
      end
    end

    context "due today" do
      let(:payment) { Bki::Payment.new(Date.today, nil) }

      it "due today" do
        expect(due).to eq(true)
      end
    end
  end

  # ------------------------------------------------------------
  describe "#paid" do
    let(:payment) { Bki::Payment.new(Date.today + 1, Date.today) }

    subject(:paid) do
      payment.paid?
    end

    it "paid" do
      expect(paid).to eq(true)
    end

    context "no paid" do
      let(:payment) { Bki::Payment.new(Date.today - 1, nil) }

      it "no paid" do
        expect(paid).to eq(false)
      end
    end
  end

  # # ------------------------------------------------------------
  describe "#active_overdue" do
    let(:payment) { Bki::Payment.new(Date.today + 1, nil) }

    subject(:active_overdue) do
      payment.active_overdue?
    end

    it "active_overdue" do
      expect(active_overdue).to eq(false)
    end

    context "paid today" do
      let(:payment) { Bki::Payment.new(Date.today, Date.today) }

      it "paid today" do
        expect(active_overdue).to eq(false)
      end
    end

    context "not paid today" do
      let(:payment) { Bki::Payment.new(Date.today, nil) }

      it "not paid today" do
        expect(active_overdue).to eq(false)
      end
    end

    # платёж прошёл и оплачен
    context "yesterday payment and paid" do
      let(:payment) { Bki::Payment.new(Date.today - 1, Date.today) }

      it "yesterday payment and paid" do
        expect(active_overdue).to eq(false)
      end
    end

    # платёж прошёл и НЕ оплачен
    context "not paid today" do
      let(:payment) { Bki::Payment.new(Date.today - 1, nil) }

      it "not paid today" do
        expect(active_overdue).to eq(true)
      end
    end
  end

  # ------------------------------------------------------------
  describe "#paid_with_overdue" do
    let(:payment) { Bki::Payment.new(Date.today - 1, Date.today) }

    subject(:paid_with_overdue) do
      payment.paid_with_overdue?
    end

    it "paid_with_overdue" do
      expect(paid_with_overdue).to eq(true)
    end

    context "no_overdue" do
      let(:payment) { Bki::Payment.new(Date.today, Date.today) }

      it "no_overdue" do
        expect(paid_with_overdue).to eq(false)
      end
    end

    context "not paid today" do
      let(:payment) { Bki::Payment.new(Date.today + 1, nil) }

      it "not paid today" do
        expect(paid_with_overdue).to eq(false)
      end
    end

    context "not paid yesterday" do
      let(:payment) { Bki::Payment.new(Date.today - 1, nil) }

      it "return first date overdue" do
        expect(paid_with_overdue).to eq(false)
      end
    end

    # платёж прошёл и был оплачен в прошлом
    context "past paid" do
      let(:payment) { Bki::Payment.new(Date.today - 2, Date.today - 1) }

      it "return first date overdue" do
        expect(paid_with_overdue).to eq(true)
      end
    end
  end

  #----------------------------

  describe "#continuous_overdue?" do
    let(:payment) { Bki::Payment.new(Date.today - 5, Date.today) }
    let(:next_payment) { Bki::Payment.new(Date.today - 2, nil) }

    subject(:continuous_overdue) do
      payment.continuous_overdue?(next_payment)
    end

    it "return true" do
      expect(continuous_overdue).to eq(true)
    end

    # оба платежа оплачены в срок?
    context "payments paid no overdue" do
      let(:payment) { Bki::Payment.new(Date.today - 5, Date.today - 5) }
      let(:next_payment) { Bki::Payment.new(Date.today - 1, Date.today - 1) }

      it "return false" do
        expect(continuous_overdue).to eq(false)
      end
    end

    # текущий платёж не оплачен?
    context "current payment not paid" do
      let(:payment) { Bki::Payment.new(Date.today - 1, Date.today - 1) }
      let(:next_payment) { Bki::Payment.new(Date.today, nil) }

      it "return false" do
        expect(continuous_overdue).to eq(false)
      end
    end

    # оба платежа ещё не наступили?
    context "payment date has not arrived" do
      let(:payment) { Bki::Payment.new(Date.today + 1, nil) }
      let(:next_payment) { Bki::Payment.new(Date.today + 5, nil) }

      it "return false" do
        expect(continuous_overdue).to eq(false)
      end
    end

    # текущий платёж оплачен без просрочки?
    context "current payment paid no overdue" do
      let(:payment) { Bki::Payment.new(Date.today - 1, Date.today - 1) }
      let(:next_payment) { Bki::Payment.new(Date.today + 5, nil) }

      it "return false" do
        expect(continuous_overdue).to eq(false)
      end
    end
  end
end
