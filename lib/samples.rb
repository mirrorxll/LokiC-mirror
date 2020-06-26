# frozen_string_literal: true

require_relative 'pipeline.rb'
require_relative 'pipeline_replica.rb'
require_relative 'samples/base.rb'

module Samples
  def self.[](environment)
    Samples::Base.new(environment)
  end
end
