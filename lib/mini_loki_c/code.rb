# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class Code
    def self.[](story_type)
      new(story_type)
    end

    def download
      query = "SELECT file_blob b FROM hle_file_blobs WHERE story_type_id = #{@story_type.id};"
      blob = Connect::Mysql.exec_query(DB02, 'loki_storycreator', query).first

      blob && blob['b']
    end

    def check_updates
      load file
      story_type_class = Object.const_get("S#{@story_type.id}")
      return unless story_type_class.respond_to?(:check_updates)

      story_type_class.check_updates.to_s
    end

    def execute(method, options = {})
      load file
      story_type_class = Object.const_get("S#{@story_type.id}")

      story_type_class.include(
        MiniLokiC::Connect,
        MiniLokiC::Formatize,
        MiniLokiC::Population,
        MiniLokiC::Creation,
        MiniLokiC::NoLog
      )

      METHODS_TRACER.enable { story_type_class.new.send(method, options) }
    rescue StandardError, ScriptError => e
      raise "MiniLokiC::#{method.capitalize}ExecutionError".constantize,
            "[ #{method.capitalize}ExecutionError ] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
    end

    def file
      file = "#{Rails.root}/public/ruby_code/s#{@story_type.id}.rb"
      File.open(file, 'wb') { |f| f.write(@story_type.code.download) }

      file
    end

    private

    def initialize(story_type)
      @story_type = story_type
    end
  end
end
