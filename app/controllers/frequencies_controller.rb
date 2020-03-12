# frozen_string_literal: true

class FrequenciesController < ApplicationController # :nodoc:
  before_action :find_frequency

  def include
    render_400 && return if @story_type.frequencies.count.positive?

    @story_type.frequencies << @frequency
  end

  def exclude
    render_400 && return unless @story_type.frequencies.exists?(@frequency.id)

    @story_type.frequencies.clear
  end

  private

  def find_frequency
    @frequency = Frequency.find(params[:id])
  end
end
