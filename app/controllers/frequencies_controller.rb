# frozen_string_literal: true

class FrequenciesController < ApplicationController # :nodoc:
  before_action :find_frequency, only: :include

  def include
    render_400 && return if @story_type.frequency

    @story_type.update(frequency: @frequency)
  end

  def exclude
    render_400 && return unless @story_type.frequency

    @story_type.update(frequency: nil)
  end

  private

  def find_frequency
    @frequency = Frequency.find(params[:id])
  end
end
