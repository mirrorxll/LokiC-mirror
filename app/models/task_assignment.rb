# frozen_string_literal: true

class TaskAssignment < ApplicationRecord # :nodoc:
  belongs_to :task
  belongs_to :account
end
