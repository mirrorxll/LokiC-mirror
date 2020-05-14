# frozen_string_literal: true

require_relative 'code/functions/functions'
require_relative 'code/functions/numbers'
require_relative 'code/creation/staging_records'
require_relative 'code/creation/sample'

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class Code
    def self.execute(story_type, method, options)
      new(story_type, method, options).send(:exec)
    end

    private

    def initialize(story_type, method, options)
      @story_type = story_type
      @method = method
      @options = options.eql?(:population) ? options_to_hash(options) : options
    end

    def exec
      load file

      Object.const_get("S#{@story_type.id}").new.send(@method, @options)
    ensure
      if Object.const_defined?("S#{@story_type.id}")
        Object.send(:remove_const, "S#{@story_type.id}")
      end
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
