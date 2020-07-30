# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController # :nodoc:
  skip_before_action :find_parent_story_type

  def new
    flash[:alert] = 'Registration disabled'
    redirect_to new_account_session_path
  end

  def update
    super
    slack_account = SlackAccount.find_by(slack_account_params)
    if slack_account
      current_account.slack&.update(account: nil)
      slack_account.update(account: current_account)
    else
      flash[:alert] = 'Slack Account not found.'
    end
  end

  def slack_account_params
    params.require(:slack_account).permit(:identifier)
  end
end
