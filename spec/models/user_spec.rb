# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validações" do
    it "é válido com atributos padrão da factory" do
      expect(build(:user)).to be_valid
    end

    it "exige email único" do
      create(:user, email: "dup@example.com")
      expect(build(:user, email: "dup@example.com")).not_to be_valid
    end
  end

  describe "associações" do
    it "tem muitas contas" do
      user = create(:user)
      create(:account, user: user)
      expect(user.accounts.count).to eq(1)
    end
  end
end
