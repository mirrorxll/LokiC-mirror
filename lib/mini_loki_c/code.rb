# frozen_string_literal: true

require_relative 'population.rb'
require_relative 'creation.rb'

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class Code
    def self.execute(story_type, method, options)
      new(story_type, method, options).send(:exec)
    end

    def self.download(story_type)
      new(story_type).send(:download)
    end

    private

    def initialize(story_type, method = nil, options = {})
      @story_type = story_type
      @method = method
      @options = method.eql?(:population) ? options_to_hash(options) : options
    end

    def download
      query = "SELECT file_blob b FROM hle_file_blobs WHERE story_type_id = #{@story_type.id};"
      db05 = Connect::Mysql.on(DB05, 'loki_storycreator')
      blob = db05.query(query).first
      db05.close

      blob && blob['b']
    end

    def exec
      load file

      Object.const_get("S#{@story_type.id}").new.send(@method, @options)
    ensure
      Object.send(:remove_const, "S#{@story_type.id}") if Object.const_defined?("S#{@story_type.id}")
    end

    def file
      file = "#{Rails.root}/public/ruby_code/S#{@story_type.id}.rb"
      File.open(file, 'wb') { |f| f.write(@story_type.code.download) }

      file
    end

    def options_to_hash(options)
      options = options.split(',')
      options = options.map { |opt| opt.gsub(/[\s+,'"]/, '') }

      options.each_with_object({}) do |opt, hash|
        hash[opt.split(/[=>,:]/).first.to_s] = opt.split(/[=>,:]/).last
      end
    end
  end
end
