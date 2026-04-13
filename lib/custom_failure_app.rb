# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def respond
    if request_format == :json
      json_error_response
    else
      super
    end
  end

  def json_error_response
    self.status = 401
    self.content_type = "application/json"
    self.response_body = { erro: failure_message_json }.to_json
  end

  private

  def failure_message_json
    key = (warden_options[:message] || :unauthenticated).to_sym
    case key
    when :invalid
      "Email ou senha inválidos."
    when :unauthenticated
      "Autenticação necessária."
    else
      I18n.t("devise.failure.#{key}", default: key.to_s.humanize)
    end
  end
end
