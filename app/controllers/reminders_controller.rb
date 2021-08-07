# frozen_string_literal: true

class RemindersController < ApplicationController
  before_action :reminder

  def confirm
    render_403 and return unless @story_type.updates?

    @reminder.update!(updates_confirmed: true, current_account: current_account)
    render 'update_reminder_panel'
  end

  def disprove
    render_403 and return unless @story_type.updates?

    @reminder.update!(updates_confirmed: false, has_updates: false, current_account: current_account)
  end

  def turn_off
    render_403 and return unless @story_type.updates?

    @reminder.update!(reminder_params)
    render 'update_reminder_panel'
  end

  private

  def reminder
    @reminder = @story_type.reminder
  end

  def reminder_params
    attrs = params.require(:reminder).permit(:turn_off_until, :reasons)
    attrs[:current_account] = current_account
    attrs
  end
end
