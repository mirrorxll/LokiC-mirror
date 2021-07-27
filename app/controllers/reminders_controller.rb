# frozen_string_literal: true

class RemindersController < ApplicationController
  before_action :reminder
  after_action :confirm_to_history,  only: :confirm
  after_action :turn_off_to_history, only: :turn_off

  def confirm
    render_403 and return unless @story_type.updates?

    @reminder.update_with_acc!(current_account, updates_confirmed: true)
    render 'update_reminder_panel'
  end

  def disprove
    render_403 and return unless @story_type.updates?

    @reminder.update_with_acc!(current_account, updates_confirmed: nil, has_updates: false)
  end

  def turn_off
    render_403 and return unless @story_type.updates?

    @reminder.update_with_acc!(current_account, reminder_params)
    render 'update_reminder_panel'
  end

  private

  def reminder
    @reminder = @story_type.reminder
  end

  def reminder_params
    params.require(:reminder).permit(:turn_off_until, :reasons)
  end

  def confirm_to_history
    note = 'new data in data set confirmed'
    record_to_change_history(@story_type, 'has updates', note, current_account)
  end

  def turn_off_to_history
    note = "reminder turned off, reasons: #{@story_type.reminder.reasons}"
    record_to_change_history(@story_type, 'reminder turned off', note, current_account)
  end
end
