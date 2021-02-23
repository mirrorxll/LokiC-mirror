# frozen_string_literal: true

require_relative 'pipeline.rb'
require_relative 'pipeline_replica.rb'
require_relative 'mini_loki_c/connect/mysql.rb'
require_relative 'samples/auto_feedback_tool.rb'
require_relative 'samples/export_to_pl.rb'
require_relative 'samples/error.rb'

module Samples
  include MiniLokiC::Connect

  def self.[](environment)
    Samples::ExportToPl.new(environment)
  end

  def self.auto_feedback(story_type, confirmed = false)
    Samples::AutoFeedbackTool.new(story_type, confirmed).generate!
  end
end
