# frozen_string_literal: true

module StoryTypes
  class FrequenciesController < ApplicationController # :nodoc:
    before_action :render_403, if: :developer?
    before_action :find_frequency, only: :include

    def include
      render_403 && return if @story_type.frequency

      @story_type.update!(frequency: @frequency, current_account: current_account)
    end

    def exclude
      render_403 && return unless @story_type.frequency

      @story_type.update!(frequency: nil, current_account: current_account)
    end

    private

    def find_frequency
      @frequency = Frequency.find(params[:id])
    end
  end
end
