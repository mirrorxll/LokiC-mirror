# frozen_string_literal: true

class TaskNote < ApplicationRecord # :nodoc:
  belongs_to :task
  belongs_to :creator, class_name: 'Account'
end
