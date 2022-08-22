# frozen_string_literal: true

class TaskChecklist < ApplicationRecord # :nodoc:
  validates :description, length: { maximum: 255 }

  belongs_to :multi_task, foreign_key: :task_id
end
