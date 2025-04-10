module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: {
          message: 'Logged in successfully.',
          user: current_user,
          token: request.env['warden-jwt_auth.token']
        }, status: :ok
      end

      def respond_to_on_destroy
        head :no_content
      end
    end
  end
end
