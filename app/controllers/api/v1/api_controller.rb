# frozen_string_literal: true

module Api
  module V1
    class ApiController < ActionController::API
      before_action :authenticate_account!
      before_action :set_default_format

      private

      def set_default_format
        request.format = :json
      end
    end
  end
end
