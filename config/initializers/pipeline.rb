# frozen_string_literal: true

PL_TARGET = %w[development test].include?(Rails.env) ? :staging : :production

Pipeline.configure do |pl|
  pl.production_endpoint = Rails.application.credentials[:pipeline][:production][:endpoint]
  pl.production_token = Rails.application.credentials[:pipeline][:production][:token]

  pl.staging_endpoint = Rails.application.credentials[:pipeline][:staging][:endpoint]
  pl.staging_token = Rails.application.credentials[:pipeline][:staging][:token]

  pl.shapes_endpoint = Rails.application.credentials[:pipeline_shapes][:endpoint]
  pl.shapes_token = Rails.application.credentials[:pipeline_shapes][:token]
end
