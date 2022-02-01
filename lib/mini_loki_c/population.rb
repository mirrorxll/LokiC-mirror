# frozen_string_literal: true

require_relative 'population/publications.rb'
require_relative 'population/sql.rb'
require_relative 'population/population_success.rb'
require_relative 'population/frame.rb'
require_relative 'population/story_mixer.rb'
require_relative 'population/sidekiq_stop.rb'

module MiniLokiC
  module Population; end
end
