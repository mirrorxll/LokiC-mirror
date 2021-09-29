# frozen_string_literal: true

class TaskReceipt < ApplicationRecord # :nodoc:
  belongs_to :task
  belongs_to :assignment, class_name: 'Account'
end
