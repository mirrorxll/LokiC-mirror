# frozen_string_literal: true

class RemindersController < ApplicationController
  def confirm
    render_400 unless @story_type.updates?

    @story_type.reminder.update(updates_confirmed: true)
  end

  def disprove
    render_400 unless @story_type.updates?

    @story_type.reminder.update(has_updates: false)
  end

  def turn_off
    render_400 unless @story_type.updates?

    @story_type.update(reminder_params)
  end

  private

  def reminder_params
    params.require(:reminder).permit(:turn_off_until, :reasons)
  end
end
