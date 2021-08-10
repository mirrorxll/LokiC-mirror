# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update]

  def index
    @grid_params = request.parameters[:iteration_stories_grid] || {}
    @iteration_stories_grid = StoryTypeIterationSamplesGrid.new(@grid_params.merge(client_ids: @story_type.clients.pluck(:name, :id))) do |scope|
      scope.where(story_type_id: params[:story_type_id], iteration_id: params[:iteration_id])
    end
    @stories_count = [@iteration.stories.scheduled_count, @iteration.stories.backdated_count]
    @tab_title = "LokiC::Samples ##{@story_type.id} #{@story_type.name}"
    respond_to do |f|
      f.html do
        @iteration_stories_grid.scope do |scope|
          scope.page(params[:page])
        end
      end
      f.csv do
        send_data @iteration_stories_grid.to_csv,
                  type: 'text/csv',
                  disposition: 'inline',
                  filename: "LokiC_##{@story_type_id}_#{@story_type.name}_#{@iteration.name}_stories_#{Time.now}.csv"
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

    render 'creations/execute'
  end

  def purge_sampled
    @iteration.stories.where(sampled: true).destroy_all
    @iteration.auto_feedback_confirmations.destroy_all

    @iteration.update!(samples: nil, current_account: current_account)
    flash.now[:message] = 'stories deleted'
  end

  private

  def find_sample
    @sample = Sample.find(params[:id])
  end

  def update_section_params
    params.require(:section_update).permit(:message)
  end

  def stories_params
    params.require(:stories).permit(:row_ids, columns: {})
  end
end
