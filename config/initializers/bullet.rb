# frozen_string_literal: true

Rails.application.config.after_initialize do
  next unless defined?(Bullet)

  if Rails.env.development? || Rails.env.test?
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.bullet_logger = true
  end

  if Rails.env.test?
    Bullet.raise = true
    Bullet.unused_eager_loading_enable = false
  end
end
