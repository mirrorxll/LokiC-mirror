# frozen_string_literal: true

module Authenticates
  class RegistrationsController < AuthenticatesController
    def edit
      @tab_title = 'LokiC :: Profile'
    end

    def update
      slack_account = SlackAccount.find_by(slack_account_params)
      if slack_account
        current_account.slack&.update!(account: nil)
        slack_account.update!(account: current_account)
      end

      fact_checking_channel = FactCheckingChannel.find_by(fc_channel_params)
      return unless fact_checking_channel

      current_account.fact_checking_channel&.update!(account: nil)
      fact_checking_channel.update!(account: current_account)
    end

    private

    def slack_account_params
      params.require(:slack_account).permit(:identifier)
    end

    def fc_channel_params
      params.require(:fcd_channel).permit(:id)
    end

    def after_update_path_for(resource)
      edit_account_registration_path(resource)
    end
  end
end
