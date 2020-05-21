# frozen_string_literal: true

require_relative 'pipeline.rb'
require_relative 'pipeline_replica.rb'
require_relative 'stories/base.rb'

module Stories
  def self.[](environment)
    Stories::Base.new(environment)
  end
end
