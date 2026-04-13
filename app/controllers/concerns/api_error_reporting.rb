# frozen_string_literal: true

module ApiErrorReporting
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |e|
      raise e if e.is_a?(ActiveRecord::RecordNotFound)
      raise e if e.is_a?(ActionController::ParameterMissing)
      raise e if e.class.name.to_s.start_with?("Bullet::")

      SystemErrorMailer.with(
        message: e.message,
        backtrace: e.backtrace&.join("\n")
      ).notify.deliver_later

      render json: { erro: "Erro interno do servidor" }, status: :internal_server_error
    end
  end
end
