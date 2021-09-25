# frozen_string_literal: true

module Api
  module WorkRequests
    class InvoiceTypesController < ApiController
      def find_or_create
        invoice = InvoiceType.find_or_create_by!(invoice_param)

        render json: { type_id: invoice.id, type_name: invoice.name }
      end

      private

      def invoice_param
        params.require(:invoice_type).permit(:name)
      end
    end
  end
end
