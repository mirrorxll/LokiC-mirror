# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class StoryTypeCode
    def self.[](story_type)
      new(story_type)
    end

    def download
      blob = HleFileBlob.select(:file_blob).where(story_type_id: @story_type.id).first

      blob && blob[:file_blob]
    end

    def check_updates
      story_type_class = load_story_type_class.new
      return unless story_type_class.respond_to?(:check_updates)

      story_type_class.check_updates({})
    end

    def execute(method, options = {})
      METHODS_TRACER.enable { load_story_type_class.new.public_send(method, options) }
    rescue StandardError, ScriptError => e
      raise "#{method.capitalize}ExecutionError".constantize,
            "[ #{method.capitalize}ExecutionError ] -> #{e.message} "\
            "at #{e.backtrace.first}".gsub('`', "'")
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
