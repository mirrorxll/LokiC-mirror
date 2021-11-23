# frozen_string_literal: true

module Api
  module WorkRequests
    class ClientsController < ApiController
      def find
        client = Client.find_by(client_params)
        response = client ? { client_id: client.id, client_name: client.name } : 404

        render json: response
      end

      private

      def client_params
        params.require(:client).permit(:id, :name)
      end
    end
  end
end
