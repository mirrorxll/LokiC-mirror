# frozen_string_literal: true

module Authenticates
  class RegistrationsController < AuthenticatesController
    skip_before_action :redirect_to_root

    def edit
      @tab_title = 'LokiC :: Profile'
    end

    def update
      current_account.update(account_params)

      password = password_params
      if password[:password].present? || password[:password_confirmation].present?
        current_account.update(password)
      end

      slack_account = SlackAccount.find_by(slack_account_params)
      if slack_account != current_account.slack
        current_account.slack&.update!(account: nil)
        slack_account&.update!(account: current_account)
      end

      fcd_slack_channel = FactCheckingChannel.find_by(fcd_slack_channel_params)
      if fcd_slack_channel != current_account.fact_checking_channel
        current_account.fact_checking_channel&.update!(account: nil)
        fcd_slack_channel.update!(account: current_account)
      end

      if current_account.errors.any?
        flash[:error] = current_account.errors
      else
        flash[:success] = { success: 'profile updated' }
      end

      redirect_to profile_path
    end

    private

    def account_params
      params.require(:account).permit(:first_name, :last_name)
    end

    def slack_account_params
      params.require(:slack_account).permit(:id)
    end

    def fcd_slack_channel_params
      params.require(:fcd_slack_channel).permit(:id)
    end

    def password_params
      params.require(:secure).permit(:password, :password_confirmation)
    end
  end
end
