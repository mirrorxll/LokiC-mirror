# frozen_string_literal: true

module StoryTypes
  class FrequenciesController < StoryTypesController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :find_frequency, only: :include

    after_action :set_next_export_date

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

    def set_next_export_date
      StoryTypes::Iterations::SetNextExportDateTask.new.perform(@story_type.id)
    end
  end
end
