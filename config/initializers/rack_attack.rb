# frozen_string_literal: true

# Rack::Attack é inserido pelo Railtie. Em teste, desabilitamos em
# config/environments/test.rb para não interferir na suíte RSpec.

class Rack::Attack
  Rack::Attack.throttled_responder = lambda do |req|
    match_data = req.env["rack.attack.match_data"] || {}
    period = match_data[:period] || 60
    body = { erro: "Limite de requisições excedido. Aguarde antes de tentar novamente." }.to_json
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => period.to_s
      },
      [body]
    ]
  end

  Rack::Attack.blocklisted_responder = lambda do |_req|
    body = { erro: "Acesso bloqueado." }.to_json
    [
      403,
      { "Content-Type" => "application/json" },
      [body]
    ]
  end

  safelist("health-internal") do |req|
    req.path == "/up"
  end

  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/api-docs")
  end

  throttle("auth/ip", limit: 120, period: 1.minute) do |req|
    req.ip if req.path.match?(%r{\A/(conta|transacao)(\z|\.json)})
  end

  throttle("logins/ip", limit: 15, period: 15.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end
end

Rails.application.config.after_initialize do
  next if Rails.env.test?

  ActiveSupport::Notifications.subscribe(/\A(throttle|blocklist|fail2ban)\.rack_attack\z/) do |_name, _start, _finish, _id, payload|
    request = payload[:request]
    next unless request

    env = request.env
    matched = env["rack.attack.matched"]
    match_type = env["rack.attack.match_type"]
    discriminator = env["rack.attack.match_discriminator"]
    match_data = env["rack.attack.match_data"]

    cache_key = [
      "rack_attack_alert",
      match_type,
      matched,
      discriminator.to_s
    ].join(":")

    written = Rails.cache.write(cache_key, 1, expires_in: 10.minutes, unless_exist: true)
    next unless written

    RackAttackMailer.with(
      event: match_type.to_s,
      rule_name: matched.to_s,
      ip: request.ip,
      path: request.path,
      method: request.request_method,
      discriminator: discriminator.to_s,
      match_data: match_data.inspect,
      user_agent: request.user_agent.to_s.truncate(500)
    ).alert.deliver_later
  end
end
