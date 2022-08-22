# frozen_string_literal: true

class TaskAssignment < ApplicationRecord # :nodoc:
  belongs_to :multi_task, foreign_key: :task_id
  belongs_to :account

  def name
    account.name
  end

  def time_confirm
    confirmed_at - created_at - time_off
  end

  def done?
    done
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
