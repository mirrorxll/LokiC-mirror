# frozen_string_literal: true

class TaskChecklist < ApplicationRecord # :nodoc:
  validates :description, length: { maximum: 255 }

  belongs_to :task
end
