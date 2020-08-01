# frozen_string_literal: true

require 'nokogiri'

require_relative 'auto_feedback_generator/lists.rb'
require_relative 'auto_feedback_generator/sample_to_hash.rb'
require_relative 'auto_feedback_generator/rules.rb'

module Samples
  class AutoFeedbackTool
    include AutoFeedbackGenerator::Lists
    include AutoFeedbackGenerator::SampleToHash
    include AutoFeedbackGenerator::Rules

    def initialize(story_type)
      @iteration = story_type.iteration
      @samples = @iteration.samples.where(sampled: true).joins(:output)
      @feedback_rules = AutoFeedback.all.to_a

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
          sample_txt_part = send(fb[:rule], sample_obj)
          next unless sample_txt_part

          unless @iteration.auto_feedback.exists?(fb.id)
            @iteration.auto_feedback << fb
            @iteration.auto_feedback_confirmations.last.update(sample: sample, sample_txt_part: sample_txt_part)
          end

          confirmed << fb
        end

        confirmed_rules.each { |rule| @feedback_rules.delete(rule) }
      end
    end
  end
end
