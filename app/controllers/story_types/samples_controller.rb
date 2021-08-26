# frozen_string_literal: true

module StoryTypes
  class SamplesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :find_sample, only: %i[show edit update]

    def index
      @grid_params = request.parameters[:iteration_stories_grid] || {}

      @iteration_stories_grid = StoryTypeIterationStoriesGrid.new(@grid_params.merge(client_ids: @story_type.clients.pluck(:name, :id))) do |scope|
        scope.where(story_type_id: params[:story_type_id], story_type_iteration_id: params[:iteration_id])
      end

      @stories_count = [@iteration.stories.scheduled_count, @iteration.stories.backdated_count]
      @tab_title = "LokiC::Samples ##{@story_type.id} #{@story_type.name}"
      respond_to do |f|
        f.html do
          @iteration_stories_grid.scope { |scope| scope.page(params[:page]) }
        end
        f.csv do
          send_data @iteration_stories_grid.to_csv, type: 'text/csv', disposition: 'inline',
                    filename: "LokiC_##{@story_type.id}_#{@story_type.name}_#{@iteration.name}_stories_#{Time.now}.csv"
        end
      end
    end

    def show
      @tab_title = @sample.headline

      respond_to do |format|
        format.html { render 'show' }
        format.js { render 'to_tab' }
      end
    end

    def create_and_gen_auto_feedback
      @iteration.update!(samples: false, current_account: current_account)
      SamplesAndAutoFeedbackJob.perform_later(@iteration, current_account, stories_params)

      render 'story_types/creations/execute'
    end

    def purge_sampled
      @iteration.update!(purge_samples: false, current_account: current_account)
      PurgeSamplesJob.perform_later(@iteration, current_account)

      render 'story_types/creations/purge'
    end

    private

    def find_sample
      @sample = Story.find(params[:id])
    end

    def update_section_params
      params.require(:section_update).permit(:message)
    end

    def stories_params
      params.require(:samples).permit(:row_ids, columns: {})
    end
  end
end
