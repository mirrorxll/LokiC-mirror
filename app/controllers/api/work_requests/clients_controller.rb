# frozen_string_literal: true

module Api
  module WorkRequests
    class ClientsController < ApiController
      def find_by_name
        permitted_params = client_params
        client = Client.find_by(permitted_params) || Client.new(permitted_params)
        new_record = client.new_record?

        client.update!(exist_in_pl: false) if new_record

        render json: {
          client_id: client.id,
          client_name: client.name,
          new_record: new_record,
          exist_in_pl: client.exist_in_pl
        }
      end

      private

      def client_params
        params.require(:client).permit(:name)
      end
    end
  end
end
