# frozen_string_literal: true

class SamplesController < ApplicationController # :nodoc:
  before_action :find_sample, only: %i[show edit update]

  def index
    @all_samples = @iteration.samples
    @paged_samples = @all_samples.order(backdated: :asc).order(published_at: :asc)
                                 .page(params[:page]).includes(:output, :publication)

    @tab_title = "LokiC::Samples ##{@story_type.id} #{@story_type.name}"
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
