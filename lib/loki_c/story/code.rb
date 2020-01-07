# frozen_string_literal: true

module LokiC
  module Story
    class Code < BlobToFile # :nodoc:

      class << self
        def run(story, method, options = {})
          load file(story)

          const_get(story.module_name).method("#{method}_#{story.id}").call(story, options)
          const_get(to_s).send(:remove_const, story.module_name)
        rescue StandardError => e
          e.backtrace
        else
          false
        end
      end
    end

  end
end
