# frozen_string_literal: true

module Pipeline
  # Class for api requests to PL
  class MainClient < Base
    include MainEndpoint

    def initialize(environment)
      @environment = environment
      Pipeline.main_options(environment).each { |name, value| send("#{name}=", value) }
    end
  end
end
