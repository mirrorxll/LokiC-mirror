# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class Code
    def self.execute(iteration, method, options)
      new(iteration, method, options).send(:exec)
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

    def self.download(iteration)
      new(iteration).send(:download)
    end

    private

    def initialize(iteration, method = nil, options = {})
      @story_type = iteration.story_type
      @method = method.to_s

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
      db05 = Connect::Mysql.on(DB02, 'loki_storycreator')
      blob = db05.query(query).first
      db05.close

      blob && blob['b']
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

      story_type_class.new.send(@method, @options)
    rescue StandardError, ScriptError => e
      raise "MiniLokiC::#{@method.capitalize}ExecutionError".constantize,
            "[ #{@method.capitalize}ExecutionError ] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
    ensure
      Object.send(:remove_const, "S#{@story_type.id}") if Object.const_defined?("S#{@story_type.id}")
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
