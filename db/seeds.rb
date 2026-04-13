# frozen_string_literal: true

admin = User.find_or_initialize_by(email: "admin@example.com")
admin.password = "123456"
admin.password_confirmation = "123456"
admin.save!

Account.find_or_initialize_by(numero_conta: 10_001).tap do |account|
  account.user = admin
  account.saldo = 5000.00
  account.save!
end
