# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    before_action :set_default_format

    private

    def set_default_format
      request.format = :json
    end
  end
end
