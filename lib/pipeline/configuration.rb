# frozen_string_literal: true

module Pipeline
  # Define constants and methods
  # related to pipeline-api configuration
  module Configuration
    ACCESS_OPTIONS_KEYS = %i[
      staging_token
      staging_endpoint
      production_token
      production_endpoint
    ].freeze

    attr_accessor(*ACCESS_OPTIONS_KEYS)

    # method for set configurations
    # in a passed block
    def configure
      yield self
    end

    # @return hash of options for pl access
    def options(environment)
      {
        token: send(:"#{environment}_token"),
        endpoint: send(:"#{environment}_endpoint")
      }
    end
  end
end
