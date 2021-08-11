# frozen_string_literal: true

module StoryTypes
  class ExportedStoryTypesController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type

    before_action :set_iteration,   except: :index
    before_action :editor_report,   only: :submit_editor_report
    before_action :manager_report,  only: :submit_manager_report

    def index
      @grid_params = request.parameters[:exported_story_types_grid] || {}
      @exported_story_types_grid = ExportedStoryTypesGrid.new(@grid_params)
      @exported_story_types_grid.scope { |scope| scope.page(params[:page]).per(50) }
    end

    def show_editor_report
      @report = @iteration.exported&.editor_post_export_report
    end

    def show_manager_report
      @report = @iteration.exported.manager_post_export_report
    end

    def submit_editor_report
      @report.update!(editor_report_params)
    end

    def submit_manager_report
      @report.update!(manager_report_params)
    end

    private

    def editor_report
      @report =
        @iteration.exported.editor_post_export_report ||
        @iteration.exported
                  .create_editor_post_export_report(submitter: current_account, report_type: 'editor')
    end

    def manager_report
      @report =
        @iteration.exported.manager_post_export_report ||
        @iteration.exported
                  .create_manager_post_export_report(submitter: current_account, report_type: 'manager')
    end

    def editor_report_params
      answers = params.require(:answers).permit!
      answers.each_key { |k| answers[k] = (answers[k].eql?('true') ? true : false) if k.start_with?('q') }

      { answers: answers }
    end

    def manager_report_params
      answers = params.require(:answers).permit!

      { answers: answers }
    end
  end
end
