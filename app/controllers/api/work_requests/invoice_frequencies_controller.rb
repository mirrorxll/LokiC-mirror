# frozen_string_literal: true

module Api
  module WorkRequests
    class InvoiceFrequenciesController < ApiController
      def find_or_create
        frequency = InvoiceFrequency.find_or_create_by!(frequency_param)

        render json: { frequency_id: frequency.id, frequency_name: frequency.name }
      end

      private

      def frequency_param
        params.require(:frequency_type).permit(:name)
      end
    end
  end
end
