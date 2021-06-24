# frozen_string_literal: true

class RemindersController < ApplicationController
  after_action :confirm_to_history,  only: :confirm
  after_action :turn_off_to_history, only: :turn_off

  def confirm
    render_400 and return unless @story_type.updates?

    @story_type.reminder.update_column(:updates_confirmed, true)
    render 'update_reminder_panel'
  end

  def disprove
    render_400 and return unless @story_type.updates?

    @story_type.reminder.update_columns(updates_confirmed: nil, has_updates: false)
  end

  def turn_off
    render_400 and return unless @story_type.updates?

    @story_type.reminder.update(reminder_params)
    render 'update_reminder_panel'
  end

  private

  def reminder_params
    params.require(:reminder).permit(:turn_off_until, :reasons)
  end

  def confirm_to_history
    notes = "new data in data set confirmed by #{current_account.name}"
    record_to_change_history(@story_type, 'has updates', notes)
  end

  def turn_off_to_history
    notes = "reminder turned off by #{current_account.name}, reasons #{@story_type.reminder.reasons}"
    record_to_change_history(@story_type, 'reminder turned off', notes)
  end
end
