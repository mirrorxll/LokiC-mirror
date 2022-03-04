# frozen_string_literal: true

module Limpar
  module Configuration
    def options
      {
        email: Rails.application.credentials[:limpar][:email],
        password: Rails.application.credentials[:limpar][:password],
        endpoint: Rails.application.credentials[:limpar][:endpoint]
      }
    end
  end
end
