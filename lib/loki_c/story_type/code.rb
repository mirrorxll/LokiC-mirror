# frozen_string_literal: true

module LokiC
  module StoryType
    class Code < BlobToFile # :nodoc:

      class << self
        def run(story_type, method, options = {})
          load file(story_type)

          const_get(story_type.module_name).method(method).call(options)
          const_get(to_s).send(:remove_const, story_type.module_name)
        rescue StandardError => e
          e.backtrace
        else
          false
        end
      end
    end

  end
end
