# frozen_string_literal: true

require "rails_helper"

RSpec.describe SystemErrorMailer, type: :mailer do
  describe "#notify" do
    let(:mail) do
      described_class.with(message: "boom", backtrace: "line1\nline2").notify
    end

    it "envia para o endereço configurado" do
      expect(mail.to).to eq(["ops@example.com"])
      expect(mail.subject).to include("Erro inesperado")
    end

    it "inclui mensagem e stacktrace no corpo" do
      expect(mail.body.encoded).to include("boom")
      expect(mail.body.encoded).to include("line1")
    end
  end
end
