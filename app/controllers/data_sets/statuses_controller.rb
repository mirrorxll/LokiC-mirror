# frozen_string_literal: true

module DataSets
  class StatusesController < DataSetsController
    before_action :find_data_set
    before_action :find_status

    def update
      @data_set.update(status: @status)
      return unless params[:reasons]

      @data_set.status_comment.update(body: params[:reasons])
    end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
