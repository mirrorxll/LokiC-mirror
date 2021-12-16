# frozen_string_literal: true

class TaskAssignment < ApplicationRecord # :nodoc:
  belongs_to :task
  belongs_to :account

  after_destroy do
    task.checklists_assignments_for(account).each { |checklist_assignment| checklist_assignment.destroy }
  end

  after_create do
    task.checklists.each { |checklist| TaskChecklistAssignment.create!(task: task, account: account, checklist: checklist) }
  end

  def name
    account.name
  end

  def time_confirm
    confirmed_at - created_at - time_off
  end

  private

  def time_off
    time_off = 0
    dates = created_at.to_date..confirmed_at.to_date
    dates.each_with_index do |date, index|
      next unless day_off?(date)

      time_off += if dates.count == 1
                    confirmed_at - created_at
                  elsif index == 0
                    created_at.end_of_day - created_at
                  elsif index == dates.count - 1
                    confirmed_at - confirmed_at.beginning_of_day
                  else
                    1.day.to_i
                  end
    end
    time_off
  end

  def day_off?(date)
    date.sunday? || date.saturday?
  end
end
