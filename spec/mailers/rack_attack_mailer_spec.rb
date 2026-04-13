# frozen_string_literal: true

require "rails_helper"

RSpec.describe RackAttackMailer, type: :mailer do
  describe "#alert" do
    let(:mail) do
      described_class.with(
        event: "throttle",
        rule_name: "req/ip",
        ip: "203.0.113.1",
        path: "/conta",
        method: "POST",
        discriminator: "203.0.113.1",
        match_data: "{:period=>60}",
        user_agent: "curl"
      ).alert
    end

    it "envia alerta de segurança" do
      expect(mail.to).to eq([ "ops@example.com" ])
      expect(mail.subject).to include("Rack::Attack")
      expect(mail.body.encoded).to include("203.0.113.1")
    end
  end
end
