# frozen_string_literal: true

require 'nokogiri'

require_relative 'feedback_generator/lists.rb'
require_relative 'feedback_generator/sample_to_hash.rb'
require_relative 'feedback_generator/rules.rb'

module Samples
  class FeedbackTool
    include FeedbackGenerator::Lists
    include FeedbackGenerator::SampleToHash
    include FeedbackGenerator::Rules

    def initialize(story_type)
      @iteration = story_type.iteration
      @samples = @iteration.samples.where(sampled: true).joins(:output)
      @feedback_rules = Feedback.all.to_a

      @db02 = Samples::Mysql.on(DB02, 'loki_storycreator')
      @states = list_states
      @contractions = list_contractions
      @addr_abbr = list_address_abbr
      @db02.close
    end

    def generate!
      @samples.each do |sample|
        sample_obj = prepare(sample)

        confirmed_rules = @feedback_rules.each_with_object([]) do |fb, confirmed|
          next unless send(fb[:rule], sample_obj)

          @iteration.feedback << fb unless @iteration.feedback.exists?(fb.id)
          confirmed << fb
        end

        confirmed_rules.each { |rule| @feedback_rules.delete(rule) }
      end
    end
  end
end
