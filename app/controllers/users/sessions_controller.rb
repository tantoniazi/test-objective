# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      message: "Login realizado com sucesso",
      user: { id: resource.id, email: resource.email }
    }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end
end
