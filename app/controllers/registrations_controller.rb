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
    end

    fc_channel = FcChannel.find_by(fc_channel_params)
    if fc_channel
      current_account.fc_channel.update(account: nil)
      fc_channel.update(account: current_account)
    end
  end

  def slack_account_params
    params.require(:slack_account).permit(:identifier)
  end

  def fc_channel_params
    params.require(:fcd_channel).permit(:id)
  end

  private

  def after_update_path_for(resource)
    edit_account_registration_path(resource)
  end
end
