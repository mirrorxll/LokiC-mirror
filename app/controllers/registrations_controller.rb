# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController # :nodoc:
  skip_before_action :find_parent_story_type
  skip_before_action :find_parent_article_type
  skip_before_action :set_story_type_iteration
  skip_before_action :set_article_type_iteration

  def new
    flash[:alert] = 'Registration disabled'
    redirect_to new_account_session_path
  end

  def edit
    @tab_title = "LokiC :: Profile"
  end

  def update
    super
    slack_account = SlackAccount.find_by(slack_account_params)
    if slack_account
      current_account.slack&.update!(account: nil)
      slack_account.update!(account: current_account)
    end

    fact_checking_channel = FactCheckingChannel.find_by(fc_channel_params)
    if fact_checking_channel
      current_account.fact_checking_channel&.update!(account: nil)
      fact_checking_channel.update!(account: current_account)
    end
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
