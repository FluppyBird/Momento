class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  respond_to :json

  def create
    build_resource(sign_up_params)

    if resource.save
      render json: {
        message: "Sign up successful",
        user: resource.as_json(only: [:id, :email, :username])
      }, status: :created
    else
      render json: {
        error: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username)
  end
end
