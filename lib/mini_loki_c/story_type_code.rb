# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class StoryTypeCode
    def self.[](story_type)
      new(story_type)
    end

    def download
      query = "SELECT file_blob b FROM hle_file_blobs WHERE story_type_id = #{@story_type.id};"
      blob = Connect::Mysql.exec_query(DB02, 'loki_storycreator', query).first

      blob && blob['b']
    end

    def check_updates
      story_type_class = load_story_type_class.new
      pp '>'*50, story_type_class
      story_type_class.check_updates({})
    end

    def execute(method, options = {})
      METHODS_TRACER.enable { load_story_type_class.new.public_send(method, options) }
    rescue StandardError, ScriptError => e
      path = e.backtrace.first
      at = path[/s#{@story_type.id}/] ? " at #{path}" : ''

      raise "#{method.capitalize}ExecutionError".constantize,
            "[ #{method.capitalize}ExecutionError ] -> #{e.message}#{at}".gsub('`', "'")
    end

    private

    def initialize(story_type)
      @story_type = story_type
    end

    def load_story_type_class
      file = "#{Rails.root}/public/ruby_code/s#{@story_type.id}.rb"
      File.open(file, 'wb') { |f| f.write(@story_type.code.download) }

      load file
      story_type_class = Object.const_get("S#{@story_type.id}")

      story_type_class.include(
        MiniLokiC::Connect,
        MiniLokiC::Formatize,
        MiniLokiC::Population,
        MiniLokiC::Creation,
        MiniLokiC::NoLog
      )

      story_type_class
    end
  end
end
