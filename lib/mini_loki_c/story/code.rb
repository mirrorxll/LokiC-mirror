require_relative 'code/functions/functions'
require_relative 'code/functions/numbers'
require_relative '../../../config/databases'
require_relative '../connect/mysql'
require_relative '../story'
require_relative 'code/creation/staging_records'
require_relative 'code/creation/story'
require_relative 'code/creation/iteration'

module MiniLokiC
  module Story
    class Code < BlobToFile # :nodoc:
      class << self
        def run(story_type: nil, story_type_id: nil, method: nil, options: {})
          story_type_id =
            if story_type
              load file(story_type)
              story_type.id
            elsif story_type_id
              file = find_file(story_type_id)
              load file
              story_type_id
            else
              raise ArgumentError, '.......'
            end

          const_get("S#{story_type_id}").method(method).call(options)
          send(:remove_const, "S#{story_type_id}")
        rescue StandardError => e
          puts e.backtrace
        else
          false
        end

        def find_file(story_type_id)
          Dir['loki_c/hle/*'].find { |f| f[/^mini_loki_c\/hle\/s#{story_type_id}/] }
        end
      end
    end
  end
end
