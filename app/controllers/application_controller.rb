# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Devise::Controllers::Helpers

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    render json: { erro: "Não encontrado" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { erro: e.message }, status: :bad_request
  end
end
