class Api::V1::SessionsController < ApplicationController
  # POST /api/v1/signin
  def create
    user = User.find_by(username: params[:username])
        
    if user&.authenticate(params[:password])
      token = generate_token(user)
      render json: { 
        user: { id: user.id, username: user.username }, 
        token: token 
      }
    else
      render json: { error: "invalid credentials" }, status: :unauthorized
    end
  end

  private
      
  def generate_token(user)
    payload = user.to_token_payload
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end
