# frozen_string_literal: true

class FrequenciesController < ApplicationController # :nodoc:
  before_action :find_story
  before_action :find_frequency

  def include
    return if @story.frequencies.count.positive?

    @story.frequencies << @frequency
  end

  def exclude
    return unless @story.frequencies.exists?(@frequency.id)

    @story.frequencies.clear
  end

  private

  def find_story
    @story = Story.find(params[:story_id])
  end

  def find_frequency
    @frequency = Frequency.find(params[:id])
  end
end
