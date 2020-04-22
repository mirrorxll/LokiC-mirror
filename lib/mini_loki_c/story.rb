# frozen_string_literal: true

module MiniLokiC
  module Story
    class BlobToFile # :nodoc:
      def self.file(story)
        file = "#{Rails.root}/lib/mini_loki_c/story/code/#{story.filename}.rb"
        File.open(file, 'wb') { |f| f.write(story.code.download) }

        file
      end
    end
  end
end
