# frozen_string_literal: true

class Task < ApplicationRecord # :nodoc:
  belongs_to :creator, class_name: 'Account'

  has_many :tasks_assignments, class_name: 'TaskAssignment'
  has_many :assignment_to, through: :tasks_assignments, source: :account
end
