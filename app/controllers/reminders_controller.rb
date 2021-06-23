# frozen_string_literal: true

class RemindersController < ApplicationController
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
end
