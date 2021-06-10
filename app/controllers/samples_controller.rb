# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update]

  def index
    @grid_params = request.parameters[:iteration_samples_grid] || {}
    @iteration_samples_grid = IterationSamplesGrid.new(@grid_params.merge(client_ids: @story_type.clients.pluck(:name, :id))) do |scope|
      scope.where(story_type_id: params[:story_type_id], iteration_id: params[:iteration_id])
    end
    @samples_count = [@iteration.samples.scheduled_count, @iteration.samples.backdated_count]
    @tab_title = "LokiC::Samples ##{@story_type.id} #{@story_type.name}"
    respond_to do |f|
      f.html do
        @iteration_samples_grid.scope do |scope|
          scope.page(params[:page])
        end
      end
      f.csv do
        send_data @iteration_samples_grid.to_csv,
                  type: 'text/csv',
                  disposition: 'inline',
                  filename: "LokiC_##{@story_type_id}_#{@story_type.name}_#{@iteration.name}_samples_#{Time.now}.csv"
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

  def create_and_generate_auto_feedback
    @iteration.update(story_samples: false)
    SamplesAndAutoFeedbackJob.perform_later(@iteration, samples_params)

    render 'creations/execute'
  end

  def purge_sampled
    @iteration.samples.where(sampled: true).destroy_all
    @iteration.auto_feedback_confirmations.destroy_all

    @iteration.update(story_samples: nil)
    flash.now[:message] = 'samples deleted'
  end

  private

  def find_sample
    @sample = Sample.find(params[:id])
  end

  def update_section_params
    params.require(:section_update).permit(:message)
  end

  def samples_params
    params.require(:samples).permit(:row_ids, columns: {})
  end
end
