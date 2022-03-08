# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/article creation code
  class ArticleTypeCode
    def self.[](article_type)
      new(article_type)
    end

    def download
      query = "SELECT file_blob b FROM hle_file_article_type_blobs WHERE article_type_id = #{@article_type.id};"
      blob = Connect::Mysql.exec_query(DB02, 'loki_storycreator', query).first

      blob && blob['b']
    end

    def execute(method, options = {})
      METHODS_TRACER.enable { load_article_type_class.new.public_send(method, options) }
    rescue StandardError, ScriptError => e
      path = e.backtrace.first
      at = path[/a#{@article_type.id}/] ? " at #{path}" : ''

      raise "#{method.capitalize}ExecutionError".constantize,
            "[ #{method.capitalize}ExecutionError ] -> #{e.message}#{at}".gsub('`', "'")
    end

    private

    def initialize(article_type)
      @article_type = article_type
    end

    def load_article_type_class
      file = "#{Rails.root}/public/ruby_code/a#{@article_type.id}.rb"
      File.open(file, 'wb') { |f| f.write(@article_type.code.download) }

      load file
      article_type_class = Object.const_get("A#{@article_type.id}")

      article_type_class.include(
        MiniLokiC::Connect,
        MiniLokiC::Formatize,
        MiniLokiC::Population,
        MiniLokiC::Creation,
        MiniLokiC::NoLog
      )

      article_type_class
    end
  end
end
