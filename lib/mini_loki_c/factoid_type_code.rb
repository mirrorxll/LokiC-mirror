# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/article creation code
  class FactoidTypeCode
    def self.[](factoid_type)
      new(factoid_type)
    end

    def download
      blob = HleFileArticleTypeBlob.select(:file_blob).where(article_type_id: @factoid_type.id).first

      blob && blob[:file_blob]
    end

    def execute(method, options = {})
      METHODS_TRACER.enable { load_factoid_type_class.new.public_send(method, options) }
    rescue StandardError, ScriptError => e
      raise "#{method.capitalize}ExecutionError".constantize,
            "[ #{method.capitalize}ExecutionError ] -> #{e.message} "\
            "at #{e.backtrace.first}".gsub('`', "'")
    end

    private

    def initialize(factoid_type)
      @factoid_type = factoid_type
    end

    def load_factoid_type_class
      file = "#{Rails.root}/public/ruby_code/f#{@factoid_type.id}.rb"
      File.open(file, 'wb') { |f| f.write(factoid_type_code) }

      load file
      factoid_type_class = Object.const_get("F#{@factoid_type.id}")

      factoid_type_class.include(
        MiniLokiC::Connect,
        MiniLokiC::Formatize,
        MiniLokiC::Population,
        MiniLokiC::Creation,
        MiniLokiC::NoLog
      )

      factoid_type_class
    end

    def factoid_type_code
      code = @factoid_type.code.download
      code.sub!(/class\s[A|F]/, 'class F')
      code.sub!(/STAGING_TABLE\s*=\s*[\'|\"][a|f]/, "STAGING_TABLE = 'f")
    end
  end
end
