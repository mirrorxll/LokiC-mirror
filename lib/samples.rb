# frozen_string_literal: true

require_relative 'pipeline.rb'
require_relative 'pipeline_replica.rb'
require_relative 'mini_loki_c/connect/mysql.rb'

module Samples
  include MiniLokiC::Connect

  def self.[](environment)
    Samples::Export.new(environment)
  end

  def self.feedback(story_type)
    Samples::FeedbackTool.new(story_type).generate!
  end
end
