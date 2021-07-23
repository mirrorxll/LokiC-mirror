# frozen_string_literal: true

class FrequenciesController < ApplicationController # :nodoc:
  before_action :render_403, if: :developer?
  before_action :find_frequency, only: :include

  def include
    render_403 && return if @story_type.frequency

    @story_type.update(frequency: @frequency)
  end

  def exclude
    render_403 && return unless @story_type.frequency

    @story_type.update(frequency: nil)
  end

  private

  def find_frequency
    @frequency = Frequency.find(params[:id])
  end
end
