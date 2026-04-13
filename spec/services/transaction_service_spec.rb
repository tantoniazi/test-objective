# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionService, type: :service do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, saldo: 1000) }

  describe "#call" do
    it "Pix debita o valor sem taxa" do
      described_class.new(account, "P", 100).call
      expect(account.reload.saldo).to eq(BigDecimal("900"))
    end

    it "Débito aplica taxa de 3%" do
      described_class.new(account, "D", 100).call
      expect(account.reload.saldo).to eq(BigDecimal("897"))
    end

    it "Crédito aplica taxa de 5% sobre o valor recebido" do
      described_class.new(account, "C", 100).call
      expect(account.reload.saldo).to eq(BigDecimal("1095"))
    end

    it "retorna erro quando saldo insuficiente no débito" do
      account.update!(saldo: 50)
      result = described_class.new(account, "D", 100).call
      expect(result[:sucesso]).to be false
      expect(result[:erro]).to eq("Saldo insuficiente")
      expect(account.reload.saldo).to eq(BigDecimal("50"))
    end

    it "retorna erro para forma de pagamento inválida" do
      result = described_class.new(account, "X", 10).call
      expect(result[:sucesso]).to be false
    end

    it "persiste transação" do
      expect do
        described_class.new(account, "P", 10).call
      end.to change(Transaction, :count).by(1)
    end
  end
end
