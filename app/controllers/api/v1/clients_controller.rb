# frozen_string_literal: true

module Api
  module V1
    class ClientsController < ApiController
      def visible
        @visible = Client.where(hidden: false).order(:name)

        render json: { visible: @visible }
      end

      def tags
        @tags = Client.find(params[:client_id]).tags.order(:name)

        render json: { attached: @tags }
      end

      def publications
        @publications = Client.find(params[:client_id]).publications.order(:name)

        render json: { attached: @publications }
      end
    end
  end
end
