# frozen_string_literal: true

class RackAttackMailer < ApplicationMailer
  def alert
    @event = params[:event]
    @rule_name = params[:rule_name]
    @ip = params[:ip]
    @path = params[:path]
    @method = params[:method]
    @discriminator = params[:discriminator]
    @match_data = params[:match_data]
    @user_agent = params[:user_agent]

    mail(
      to: "ops@example.com",
      subject: "[Segurança] Rack::Attack — #{@event} (#{@rule_name})"
    )
  end
end
