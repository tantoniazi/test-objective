# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account, type: :model do
  it "é válido pela factory" do
    expect(build(:account)).to be_valid
  end

  it "exige numero_conta único" do
    create(:account, numero_conta: 99_999)
    dup = build(:account, numero_conta: 99_999)
    expect(dup).not_to be_valid
  end

  it "não permite saldo negativo" do
    account = build(:account, saldo: -1)
    expect(account).not_to be_valid
  end
end
