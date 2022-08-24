# frozen_string_literal: true

class MultiTaskChecklist < ApplicationRecord # :nodoc:
  validates :description, length: { maximum: 255 }

  belongs_to :multi_task
end
