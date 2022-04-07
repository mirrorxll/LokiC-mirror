# frozen_string_literal: true

require_relative 'samples/error.rb'

module Samples
  include MiniLokiC::Connect

  def self.[](environment)
    Samples::ExportToPl.new(environment)
  end

  def self.auto_feedback(iteration, confirmed = false)
    Samples::AutoFeedbackTool.new(iteration, confirmed).generate!
  end
end
