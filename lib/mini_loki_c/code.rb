# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class Code
    def self.download(story_type)
      new(story_type: story_type).send(:download)
    end

    def self.check_updates(story_type)
      new(story_type: story_type).send(:check_updates)
    end

    def self.execute(story_type, method, options = {})
      new(story_type: story_type, method: method, options: options).send(:exec)
      # thr = Thread.new { new(iteration, method, options).send(:exec) }
      # thr.abort_on_exception = true
      #
      # if %i[population creation].include?(method.to_sym)
      #   while thr.alive?
      #     iteration.send("kill_#{method}?") ? Thread.kill(thr) : sleep(2)
      #   end
      # else
      #   thr.join
      # end
    end

    private

    def initialize(story_type:, method: nil, options: nil)
      @story_type = story_type
      @method = method

      @options =
        case method
        when :population
          options_to_hash(options[:population_args])
        when :creation
          options[:iteration] = iteration
          options
        else
          options
        end
    end

    def download
      query = "SELECT file_blob b FROM hle_file_blobs WHERE story_type_id = #{@story_type.id};"
      blob = Connect::Mysql.exec_query(DB02, 'loki_storycreator', query).first

      blob && blob['b']
    end

    def check_updates
      load file
      Object.const_get("S#{@story_type.id}").new.send(:check_updates)
    end

    def exec
      load file
      story_type_class = Object.const_get("S#{@story_type.id}")

      story_type_class.include(
        MiniLokiC::Connect,
        MiniLokiC::Formatize,
        MiniLokiC::Population,
        MiniLokiC::Creation,
        MiniLokiC::NoLog
      )

      METHODS_TRACER.enable { story_type_class.new.send(@method, @options) }
    rescue StandardError, ScriptError => e
      raise "MiniLokiC::#{@method.capitalize}ExecutionError".constantize,
            "[ #{@method.capitalize}ExecutionError ] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
    end

    def file
      file = "#{Rails.root}/public/ruby_code/s#{@story_type.id}.rb"
      File.open(file, 'wb') { |f| f.write(@story_type.code.download) }

      file
    end

    def options_to_hash(options)
      options.split(' :: ').each_with_object({}) do |option, hash|
        next unless option.match?(/=>/)

        key, value = option.split('=>')
        hash[key] = value
      end
    end
  end
end
