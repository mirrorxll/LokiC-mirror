# frozen_string_literal: true

class TaskNote < ApplicationRecord # :nodoc:
  belongs_to :multi_task, foreign_key: :task_id
  belongs_to :creator, class_name: 'Account'
end
