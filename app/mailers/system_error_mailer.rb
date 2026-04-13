# frozen_string_literal: true

class SystemErrorMailer < ApplicationMailer
  def notify
    @message = params[:message]
    @backtrace = params[:backtrace]

    mail(
      to: "ops@example.com",
      subject: "[Test Objective] Erro inesperado na API"
    )
  end
end
