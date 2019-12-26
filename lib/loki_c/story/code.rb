# frozen_string_literal: true

module LokiC
  module Story
    class Code < BlobToFile # :nodoc:
      def self.run(story, method, options = {})
        load load_file(story)
        const_get(story.module_name).method("#{method}_#{story.id}").call(options)
        const_get(to_s).send(:remove_const, story.module_name)
      end
    end
  end
end
