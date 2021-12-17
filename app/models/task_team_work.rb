# frozen_string_literal: true

class TaskTeamWork < ApplicationRecord # :nodoc:
  belongs_to :task
  belongs_to :creator, class_name: 'Account'
end
