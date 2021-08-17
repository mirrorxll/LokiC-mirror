# frozen_string_literal: true

module ArticleTypes
  class IterationsController < ApplicationController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :editor?
    before_action :find_iteration, only: %i[show update apply purge]
    before_action :find_staging_table, only: :purge

    def show
      @article_type = @iteration.article_type

      render 'article_types/show'
    end

    def create
      @iteration = @article_type.iterations.create!(iteration_params)

      @article_type.update!(current_iteration: @iteration, current_account: current_account)
      @article_type.staging_table&.default_iter_id

      redirect_to @article_type
    end

    def update
      @iteration.update!(iteration_params)
    end

    def apply
      @article_type.update!(current_iteration: @iteration, current_account: current_account)
      @article_type.staging_table&.default_iter_id

      redirect_to @article_type
    end

    def purge
      staging_table_action { @staging_table.purge }

      if flash.now[:error].nil?
        @story_type.update!(export_configurations_created: nil, current_account: current_account)
        @iteration.stories.destroy_all
        @iteration.auto_feedback.destroy_all

        @iteration.update!(
          population: nil, samples: nil,
          creation: nil, schedule: nil, export: nil,
          current_account: current_account
        )
      end

      render 'article_types/show'
    end

    private

    def find_iteration
      @iteration = ArticleTypeIteration.find(params[:id])
    end

    def find_staging_table
      @staging_table = @story_type.staging_table
    end

    def iteration_params
      permitted = params.require(:iteration).permit(:name)

      {
        name: permitted[:name],
        current_account: current_account
      }
    end
  end
end
