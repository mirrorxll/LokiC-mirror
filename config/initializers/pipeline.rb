# frozen_string_literal: true

Pipeline.configure do |pl|
  pl.production_endpoint = Rails.application.credentials.pipeline[:production][:endpoint]
  pl.production_token = Rails.application.credentials.pipeline[:production][:token]

  pl.staging_endpoint = Rails.application.credentials.pipeline[:staging][:endpoint]
  pl.staging_token = Rails.application.credentials.pipeline[:staging][:token]
end
