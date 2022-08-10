# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/article creation code
  class ArticleTypeCode
    def self.[](factoid_type)
      new(factoid_type)
    end

    def download
      # TODO: do we need to rename article_type_id in hle_file_article_type_blobs?
      query = "SELECT file_blob b FROM hle_file_article_type_blobs WHERE article_type_id = #{@factoid_type.id};"
      blob = Connect::Mysql.exec_query(DB02, 'loki_storycreator', query).first

      blob && blob['b']
    end

    def execute(method, options = {})
      pp '11111111111111'*100, method, options
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
      File.open(file, 'wb') { |f| f.write(@factoid_type.code.download) }

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
  end
end
