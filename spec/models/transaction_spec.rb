# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transaction, type: :model do
  it "é válido pela factory" do
    expect(build(:transaction)).to be_valid
  end

  it "rejeita forma_pagamento inválida" do
    t = build(:transaction, forma_pagamento: "X")
    expect(t).not_to be_valid
  end
end
