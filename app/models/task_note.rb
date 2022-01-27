# frozen_string_literal: true

class TaskNote < ApplicationRecord # :nodoc:
  has_rich_text :body

  belongs_to :task
  belongs_to :creator, class_name: 'Account'
end
