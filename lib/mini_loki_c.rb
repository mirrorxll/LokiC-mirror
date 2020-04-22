# frozen_string_literal: true

module MiniLokiC #nodoc
  require_relative 'mini_loki_c/story/code'

  def self.run(*args)
    options = derive_options({})
    raise ArgumentError, "Please pass correct'--method' argument." if options['method'] != 'population' && options['method'] != 'creation'
    MiniLokiC::Story::Code.run(story_type_id: options['story_id'], method: options['method'], options: options)
  end
end
