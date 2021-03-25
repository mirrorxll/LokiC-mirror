# frozen_string_literal: true

require_relative 'pipeline/error.rb'
require_relative 'pipeline/configuration.rb'
require_relative 'pipeline/base.rb'
require_relative 'pipeline/main_client.rb'
require_relative 'pipeline/shapes_client.rb'

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
