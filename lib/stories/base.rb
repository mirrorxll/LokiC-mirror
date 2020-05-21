# frozen_string_literal: true

require_relative 'export.rb'

module Stories
  class Base
    def initialize(environment)
      @pl_client = Pipeline[environment]
    end

    def export(story_type, options = {})
      Stories::Export.new(@pl_client, story_type, options).export!
    end
  end
end
