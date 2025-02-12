# Нужно сделать класс Payment.
# У Payment должно быть два поля:
#     дата платежа
#     дата оплаты

# Методы платежа:
#     оплачен он или нет?
#     оплачен с просрочкой?
# В проекте уже есть класс Payment, по-этому новый класс стоит либо завернуть в namespace, например BKI (глобально задача из БКИ)

# На каждый метод платежа нужно написать тесты

# Срочный - это который еще не наступил или сегодня
# Оплачен - это когда есть дата оплаты
# require 'date'

module BKI
  class Payment
    def initialize(date, paid_date)
      @date = date
      @paid_date = paid_date
    end

    def due? # срочный он или нет?
      @date <= Date.today
    end

    def paid? # оплачен он или нет?
      @paid_date.present?
    end

    def active_overdue? # есть ли по нему активная просрочка?
      !paid? && !due?
    end

    def paid_with_overdue? # оплачен с просрочкой?
      paid? && (@paid_date > @date)
    end
  end
end

# ------------------------------------------------------------
RSpec.describe do
  subject(:due) do
    BKI::Payment.new(date, paid_date).due?
  end

  let(:date) { Date.today + 1 }
  let(:paid_date) { nil }

  it "return true due" do
    expect(due).to eq(false)
  end

  context "no overdue" do
    let(:date) { Date.today - 1 }
    let(:paid_date) { nil }

    it "rno overdue" do
      expect(due).to eq(true)
    end
  end

  context "due today" do
    let(:date) { Date.today }
    let(:paid_date) { nil }

    it "due today" do
      expect(due).to eq(true)
    end
  end
end

# ------------------------------------------------------------
RSpec.describe do
  subject(:paid) do
    BKI::Payment.new(date, paid_date).paid?
  end

  let(:date) { Date.today + 1 }
  let(:paid_date) { Date.today }

  it "paid" do
    expect(paid).to eq(true)
  end

  context "no paid" do
    let(:date) { Date.today - 1 }
    let(:paid_date) { nil }

    it "no paid" do
      expect(paid).to eq(false)
    end
  end
end

# ------------------------------------------------------------
RSpec.describe do
  subject(:active_overdue) do
    BKI::Payment.new(date, paid_date).active_overdue?
  end

  let(:date) { Date.today + 1 }
  let(:paid_date) { nil }

  it "active_overdue" do
    expect(active_overdue).to eq(true)
  end

  context "paid today" do
    let(:date) { Date.today }
    let(:paid_date) { Date.today }

    it "paid today" do
      expect(active_overdue).to eq(false)
    end
  end

  context "not paid today" do
    let(:date) { Date.today }
    let(:paid_date) { nil }

    it "not paid today" do
      expect(active_overdue).to eq(false)
    end
  end
end

# ------------------------------------------------------------
RSpec.describe do
  subject(:paid_with_overdue) do
    BKI::Payment.new(date, paid_date).paid_with_overdue?
  end

  let(:date) { Date.today - 1 }
  let(:paid_date) { Date.today }

  it "paid_with_overdue" do
    expect(paid_with_overdue).to eq(true)
  end

  context "paid_without_overdue" do
    let(:date) { Date.today }
    let(:paid_date) { Date.today }

    it "paid_without_overdue" do
      expect(paid_with_overdue).to eq(false)
    end
  end

  context "not paid today" do
    let(:date) { Date.today }
    let(:paid_date) { nil }

    it "not paid today" do
      expect(paid_with_overdue).to eq(false)
    end
  end

  context "not paid yesterday" do
    let(:date) { Date.today - 1 }
    let(:paid_date) { nil }

    it "return first date overdue" do
      expect(paid_with_overdue).to eq(false)
    end
  end
end
