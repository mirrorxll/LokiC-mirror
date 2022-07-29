# frozen_string_literal: true

class TaskTeamWork < ApplicationRecord # :nodoc:
  belongs_to :multi_task, foreign_key: :task_id
  belongs_to :creator, class_name: 'Account'

  def self.done
    joins(:task).where('status_id=?', Status.find_by(name: 'done'))
  end
end
