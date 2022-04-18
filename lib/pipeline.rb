# frozen_string_literal: true

require_relative 'pipeline/error.rb'

# pipeline-api library.
# It gives the HLE-developers team
# access to a Pipeline via api
module Pipeline
  extend Configuration

  def self.[](environment)
    case environment.to_sym
    when :shapes
      Pipeline::ShapesClient.new
    when :staging, :production
      Pipeline::MainClient.new(environment)
    else
      raise EnvironmentError
    end
  end
end

Pipeline.configure do |pl|
  pl.production_endpoint = Rails.application.credentials[:pipeline][:production][:endpoint]
  pl.production_token = Rails.application.credentials[:pipeline][:production][:token]

  pl.staging_endpoint = Rails.application.credentials[:pipeline][:staging][:endpoint]
  pl.staging_token = Rails.application.credentials[:pipeline][:staging][:token]

  pl.shapes_endpoint = Rails.application.credentials[:pipeline_shapes][:endpoint]
  pl.shapes_token = Rails.application.credentials[:pipeline_shapes][:token]
end
