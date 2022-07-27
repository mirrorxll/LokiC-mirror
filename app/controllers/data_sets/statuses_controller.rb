# frozen_string_literal: true

module DataSets
  class StatusesController < DataSetsController
    before_action :find_data_set
    before_action :find_status
    before_action :find_status_comment

    def update
      @data_set.update(status: @status)
      return unless params[:reasons]

      @status_comment.update(body: params[:reasons])
    end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
