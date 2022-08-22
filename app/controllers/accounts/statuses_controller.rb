# frozen_string_literal: true

module Accounts
  class StatusesController < AccountsController
    before_action :find_account
    before_action :find_status
    before_action :find_status_comment

    def update
      @account.update(status: @status)
      return unless params[:reasons]

      @status_comment.update(body: params[:reasons])
    end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
