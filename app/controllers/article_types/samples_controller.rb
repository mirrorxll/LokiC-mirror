# frozen_string_literal: true

module ArticleTypes
  class SamplesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :find_sample, only: %i[show edit update]

    def show
      respond_to do |format|
        format.html { render 'show' }
        format.js { render 'to_tab' }
      end
    end

    def generate
      @iteration.update!(samples: false, current_account: current_account)
      SamplesJob.perform_later(@iteration, current_account, stories_params)

      render 'article_types/creations/execute'
    end

    def purge
      @iteration.update!(purge_samples: false, current_account: current_account)
      PurgeSamplesJob.perform_later(@iteration, current_account)

      render 'article_types/creations/purge'
    end

    private

    def find_sample
      @sample = Article.find(params[:id])
    end

    def update_section_params
      params.require(:section_update).permit(:message)
    end

    def stories_params
      params.require(:samples).permit(:row_ids, columns: {})
    end
  end
end
